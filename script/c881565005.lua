--Armstrong, Marshall Mastermind
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Cannot be Normal Summoned/Set.
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    --Must be Special Summoned (from your Hand) by sending 3 monsters to the GY (2 level 5 Tuners you control or in your hand and 1 monster on the field).
 	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

    	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)

    --Unaffected by the activated effects of monsters with equal or less attack to this card
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)

    -- If this card in your monster zone would be destroyed, you can add 1 "Revengeance of the Desperados" from your GY to your hand, instead. 
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(s.reptg)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)

end
s.listed_names={CARD_REVENGEANCE} --Revengeance of the Desperados


function s.cfilter(c,tp)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_HAND,LOCATION_MZONE,c)
	return #g>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end

function s.tdfilter(c,tp)
	return c:IsControler(tp) and c:IsLevel(5) and c:IsType(TYPE_TUNER)
end

function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1) and sg:FilterCount(s.tdfilter, nil,tp)>1
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_HAND,LOCATION_MZONE,c)
	local g=aux.SelectUnselectGroup(sg,e,tp,3,3,s.rescon,1,tp,HINTMSG_TOGRAVE,s.rescon)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end

function s.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsMonsterEffect() and te:IsActivated()
		and te:GetOwner():GetAttack()<=e:GetHandler():GetAttack() and te:GetOwner():GetAttack()>=0
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
    	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
            return true
        else return false end
end
function s.repfilter(c)
    return c:IsCode(CARD_REVENGEANCE) and c:IsAbleToHand()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end