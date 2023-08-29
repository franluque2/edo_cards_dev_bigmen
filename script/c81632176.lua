--Bucket-Wheel Force (CT)
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.fufilterwyrm(c)
	return c:IsFaceup() and c:IsRace(RACE_WYRM)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.fufilterwyrm, tp, LOCATION_MZONE, 0, 1, nil)
	and Duel.IsPlayerCanDiscardDeck(tp,3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
end

function s.filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp, 3)
	if Duel.DiscardDeck(tp, 3, REASON_EFFECT) then
		g=g:Filter(s.filter,nil)
		if #g>2 then
			local tc=Duel.GetFirstTarget()
			if tc:IsRelateToEffect(e) and tc:IsFaceup() then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(1500)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)

				local cards=Duel.SelectMatchingCard(tp, s.filter2 , tp, LOCATION_GRAVE, 0, 3, 3,false,nil)
				if cards then
					Duel.SendtoDeck(cards, tp, SEQ_DECKTOP, REASON_EFFECT)
					Duel.SortDecktop(tp, tp, #cards)
				end
			end
	end
end
end
