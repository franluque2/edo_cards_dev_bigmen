--闇眼の破星猫
-- NOODLE
local s,id=GetID()
function s.initial_effect(c)
	--mill 1 for piercing
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() and e:GetHandler():CanGetPiercingRush()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if #td==0 or Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)==0 then return end
	Duel.DiscardDeck(tp,2,REASON_COST)
		--Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--Piercing
			c:AddPiercing(RESETS_STANDARD_PHASE_END)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
            if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
                Duel.HintSelection(g2)
                Duel.SendtoHand(g2,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g2)
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsCode(81632766, 81632767)
end