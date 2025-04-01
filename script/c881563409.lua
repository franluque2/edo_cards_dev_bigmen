--Kid Buu, the Ultimate Fiend
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    Link.AddProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()

    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)

    local e6=WbAux.CreateDBZInstantAttackEffect(c,id)
    c:RegisterEffect(e6)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DRAGON_BALL}

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local p=e:GetHandler():GetControler()
	if d==nil then return end
	local tc=nil
	if a:GetControler()==p and d:IsStatus(STATUS_BATTLE_DESTROYED) then tc=d
	elseif d:GetControler()==p and a:IsStatus(STATUS_BATTLE_DESTROYED) then tc=a end
	if not tc then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE)
	tc:RegisterEffect(e2)
end


function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_DRAGON_BALL,lc,sumtype,tp)
end

function s.filter(c,tp)
	return c:IsSetCard(SET_DRAGON_BALL) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)

	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter, tp, LOCATION_GRAVE, 0, 1, nil,tp) and ft>0 end
	ft=math.min(ft,3)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,ft,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)

	local tg=Duel.GetTargetCards(e):Match(aux.NOT(Card.IsForbidden),nil)
	if #tg==0 then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft>0 and #tg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		tg=tg:Select(tp,ft,ft)
	end
    local c=e:GetHandler()
	for tc in tg:Iter() do
		if Duel.Equip(tp,tc,c,true,true) then
			--Equip limit
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(function(e,c) return e:GetOwner()==c end)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)

            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_EQUIP)
            e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetReset(RESET_EVENT|RESETS_STANDARD)
            e2:SetValue(600)
            tc:RegisterEffect(e2)
		end
	end
	Duel.EquipComplete()
end