--Credit Card
local s,id=GetID()
function s.initial_effect(c)


--Discard 3 other "Credit Card"; You win the Duel.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.spcost1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	--ss 1 monster from hand or grave
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(s.sstg2)
	e2:SetOperation(s.ssop2)
	c:RegisterEffect(e2)


	--Draw 3 cards.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetDescription(aux.Stringid(id, 3))
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetOperation(s.activate3)
	c:RegisterEffect(e3)

	--add 3x ulti blue eyes, then shuffle 5 back
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 4))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetOperation(s.activate4)
	c:RegisterEffect(e4)


end

function s.atohand(code,tp)
	local token=Duel.CreateToken(tp, code)
	Duel.SendtoHand(token, tp, REASON_RULE)
end

function s.shufflefilter(c)
	return c:IsAbleToDeck()
end

function s.activate4(e,tp,eg,ep,ev,re,r,rp)
	s.atohand(CARD_BLUEEYES_W_DRAGON, tp)
	s.atohand(CARD_BLUEEYES_W_DRAGON, tp)
	s.atohand(CARD_BLUEEYES_W_DRAGON, tp)
	s.atohand(CARD_BLUEEYES_W_DRAGON, tp)
	s.atohand(CARD_BLUEEYES_W_DRAGON, tp)
	s.atohand(CARD_BLUEEYES_W_DRAGON, tp)
	s.atohand(CARD_BLUEEYES_W_DRAGON, tp)
	s.atohand(CARD_BLUEEYES_W_DRAGON, tp)
	s.atohand(CARD_BLUEEYES_W_DRAGON, tp)

	s.atohand(CARD_POLYMERIZATION, tp)
	s.atohand(CARD_POLYMERIZATION, tp)
	s.atohand(CARD_POLYMERIZATION, tp)

	if Duel.IsExistingMatchingCard(s.shufflefilter, tp, LOCATION_GRAVE, 0, 1, nil) and (not Duel.IsPlayerAffectedByEffect(tp, CARD_NECROVALLEY)) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		local cards=Duel.SelectMatchingCard(tp, s.shufflefilter, tp, LOCATION_GRAVE, 0, 1, 5,false,nil)
		if #cards>0 then
			Duel.SendtoDeck(cards, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
		end
	end

end


function s.ssfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sstg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.ssop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.cfilter(c)
	return c:IsCode(id) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end

function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,3,e:GetHandler()) end
	Duel.DiscardHand(tp,s.cfilter,3,3,REASON_COST+REASON_DISCARD,e:GetHandler())
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
		Duel.Win(tp, WIN_REASON_DRAW_OF_FATE)
end

function s.activate3(e,tp,eg,ep,ev,re,r,rp)
		Duel.Draw(tp,3,REASON_EFFECT)
end
