--Melchid the Noodle Beast (CT)
--White Dog with Dark Tail (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 3 cards of deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and (c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_WATER)) and c:IsMonster()
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsMonster()
end
function s.thfilter2(c)
	return c:IsCode(81632758) and c:IsAbleToHand()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(s.cfilter,nil)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			Duel.HintSelection(g2)
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
			local g3=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_GRAVE,0,nil)
			if g2:GetFirst():IsCode(81632760) and #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				local sg=g3:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
			end
		end
	end
end
