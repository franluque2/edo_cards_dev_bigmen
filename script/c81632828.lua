--Cornfused (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_EFFECT) and Duel.IsChainDisablable(ev) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
    local token=Duel.CreateToken(tp,74983882)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
end

function s.filter(c)
	return c:IsCode(08170654,61245403,81632822,73776643,74983881,51735257)
end