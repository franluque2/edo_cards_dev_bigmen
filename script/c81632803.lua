--Decision Maker (CT)
local s,id=GetID()
function s.initial_effect(c)
    --Excavate and add WIND Zombie to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW+CATEGORY_COIN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
s.toss_coin=true
--Target: Check if the deck has at least 4 cards
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end

--Operation: Excavate, add to hand, and reorder
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,4)
	local g=Duel.GetDecktopGroup(tp,4)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=g:FilterSelect(tp,s.filter,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,sc)
	local res=Duel.TossCoin(tp,1)
	if res==COIN_HEADS then
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	elseif res==COIN_TAILS then
		Duel.SendtoHand(sc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
		Duel.ShuffleHand(tp)
	end
	local ct=#g
	if ct>0 then
		Duel.MoveToDeckBottom(ct,tp)
		Duel.SortDeckbottom(tp,tp,ct)
	end
end
function s.filter(c)
	return (c.toss_coin and c:IsMonster())
end
