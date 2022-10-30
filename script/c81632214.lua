--Big Bang Onion (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:GetReasonPlayer()==1-tp and c:IsType(TYPE_FIELD)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.fieldfilter(c)
	return c:IsCode(81632213) or c:IsCode(160202046)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.fieldfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.fieldfilter,tp,LOCATION_GRAVE,0,1,1,false,nil):GetFirst()
	if tc then
	Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
	end
end
