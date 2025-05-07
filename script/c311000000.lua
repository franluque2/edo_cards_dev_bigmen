--Virtual World Ritual (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	return true
end
function s.cfilter(c,e,tp)
	return c:IsMonster() and not c:IsPublic() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetRace(),c:GetCode())
end
function s.spfilter(c,e,tp,race,code)
	return c:IsRace(race) and not c:IsCode(code)
		and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then 
		local res=e:GetLabel()==-1 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		e:SetLabel(0)
		return res
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	e:SetLabel(rc:GetRace(),rc:GetCode())
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local race,code=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,race,code):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT) then
        Duel.ConfirmCards(1-tp,th)
	end
end
