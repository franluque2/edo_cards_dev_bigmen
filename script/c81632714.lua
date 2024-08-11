--Breath of Friendship (CT)
local s,id=GetID()
Duel.LoadScript ("big_aux.lua")
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    --Activate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,0})
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytarget)
	e2:SetOperation(s.gyactivate)
	c:RegisterEffect(e2)
    
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsOnField,tp,0,LOCATION_ONFIELD,1,c) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=Duel.SelectTarget(tp,Card.IsOnField,tp,0,LOCATION_ONFIELD,1,ct,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end
function s.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.filter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.gytarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil) end
	local sg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
end
function s.gyactivate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end