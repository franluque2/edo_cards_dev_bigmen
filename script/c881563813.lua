--Minecraft Gear: Diamond
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	--Def up
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)


    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)


    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)


end
s.listed_series={SET_MINECRAFT}
function s.funonwarrminecraftfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_MINECRAFT) and not c:IsRace(RACE_ROCK)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		 and c~=chkc and chkc:IsFaceup() and s.funonwarrminecraftfilter(chkc) end
         local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0) 
	if chk==0 then
    return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.funonwarrminecraftfilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.funonwarrminecraftfilter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end

function s.setfilter(c)
	return c:IsSetCard(SET_MINECRAFT) and c:IsSpellTrap() and c:IsSSetable()
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Equip(tp,c,tc,true)
		-- Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(function(e,c)return c==e:GetLabelObject()end)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
    
        if 	Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then

            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SSet(tp,sg)
            local tc1=sg:GetFirst()

            if tc1:IsType(TYPE_TRAP) then
                local e2=Effect.CreateEffect(e:GetHandler())
                e2:SetDescription(aux.Stringid(id,3))
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
                e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                e2:SetReset(RESET_EVENT|RESETS_STANDARD)
                tc1:RegisterEffect(e2)   
            end
            
            if tc1:IsQuickPlaySpell() then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetDescription(aux.Stringid(id,3))
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
                e1:SetReset(RESET_EVENT|RESETS_STANDARD)
                tc1:RegisterEffect(e1)
                end
		end
        end

	else
		Duel.SendtoGrave(c,REASON_RULE)
	end
end

function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,fc,sumtype,tp) and c:IsRace(RACE_ROCK,fc,sumtype,tp)
end