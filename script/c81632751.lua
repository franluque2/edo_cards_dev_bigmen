--Uninteresting Manga (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsPlayerCanDiscardDeck(1-tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tdg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(tdg,true)
	Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_COST)
    local tdg=Duel.SelectMatchingCard(1-tp,s.costfilter,1-tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(tdg,true)
	Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.costfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end