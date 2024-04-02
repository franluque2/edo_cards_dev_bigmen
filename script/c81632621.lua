--Scandal Snapper (CT)
local s, id = GetID()
function s.initial_effect(c)
	--special summon
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1, { id, 1 })
	c:RegisterEffect(e1)

	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, { id, 2 })
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2, false)
	local e3 = e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

	--special summon
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1, id)
	e4:SetCost(s.spcost2)
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)

	--Take no battle damage
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.dmgtarget)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)

	--lvup
	local e6 = Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(19012345, 0))
	e6:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_BATTLE_DAMAGE)
	e6:SetCondition(s.lvcon)
	e6:SetOperation(s.lvop)
	c:RegisterEffect(e6)

	--Can attack directly
	local e7 = Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e7)
end

function s.cfilter(c)
	return c:IsCode(05244497, 511002682, 511002683) and c:IsFaceup()
end

function s.spcon(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(s.cfilter, c:GetControler(), LOCATION_MZONE, 0, 1, nil)
end

function s.filter(c)
	return c:IsCode(100000262, 511005595, 511002684) and c:IsAbleToHand()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end

function s.lvcon(e, tp, eg, ep, ev, re, r, rp)
	return ep ~= tp and e:GetHandler():GetLevel() < 12
end

function s.lvop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(6)
	e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	Duel.ChangePosition(c, POS_FACEUP_DEFENSE)
end

function s.spcost2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
	Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD, nil)
end

function s.spcon2(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():GetAttackedCount() > 0 and Duel.GetCurrentPhase() == PHASE_MAIN2
end

function s.spfilter(c, e, tp)
	return c:IsCode(64966519) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and
	Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
end

function s.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.spop2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
	Duel.SpecialSummon(g, SUMMON_TYPE_LINK, tp, tp, false, false, POS_FACEUP)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(s.Paparazzi, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.operation2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Halve battle damage involving this card
		local e2 = Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e2:SetValue(aux.ChangeBattleDamage(0, HALF_DAMAGE))
		e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		tc:RegisterEffect(e2)
	end
end

function s.dmgtarget(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.Paparazzi(chkc) end
	if chk == 0 then return Duel.IsExistingTarget(s.Paparazzi, tp, LOCATION_MZONE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	Duel.SelectTarget(tp, s.Paparazzi, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.Paparazzi(c)
	return c:IsCode(64966519) and c:IsFaceup()
end
