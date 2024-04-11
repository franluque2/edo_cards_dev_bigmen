--Gift of the Marked
local s, id = GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c, 1, false, nil, nil)
	local e1 = Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.AddSkillProcedure(c, 1, false, s.flipcon2, s.flipop2)
end

function s.op(e, tp, eg, ep, ev, re, r, rp)
	if e:GetLabel() == 0 then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		e1:SetCountLimit(1)
		Duel.RegisterEffect(e1, tp)
		Duel.RegisterFlagEffect(tp, id + 1, 0, 0, 0)

		local c = e:GetHandler()
		local e2 = Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE + PHASE_STANDBY)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2, tp)
	end
	e:SetLabel(1)
end

function s.flipcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetCurrentChain() == 0 and Duel.GetTurnCount() == 1
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	Duel.Hint(HINT_CARD, tp, id)
	s.generatedtuners(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
end

local dtuners = {}

local dtunerstoadd = { 100000140, 100000141, 100000142, 100000143, 100000144, 100000145, 100000146 }

function s.generatedtuners(e, tp, eg, ep, ev, re, r, rp)
	for key, value in ipairs(dtunerstoadd) do
		local newcard = Duel.CreateToken(tp, value)
		table.insert(dtuners, newcard)
	end
end

function s.catastrogueaddfilter(c)
	return c:IsCode(100000143) and c:IsAbleToHand()
end

function s.icemirrorshowfilter(c)
	return c:IsCode(69492187) and not c:IsPublic()
end

function s.blizzardfilter(c, e, tp)
	return c:IsType(TYPE_MONSTER)
		and c:IsCode(100000157)
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.monsterfilter(c)
	return c:IsFaceup() and c:HasLevel()
end

function s.catastroguetributefilter(c, e, tp)
	return c:IsType(TYPE_MONSTER)
		and (c:GetFlagEffect(id) > 0)
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.dtunerfilter(c)
	return c:IsSetCard(0x600) and not c:IsPublic()
end

function s.flipcon2(e, tp, eg, ep, ev, re, r, rp)
	--OPT check
	if Duel.GetFlagEffect(tp, id + 2) > 0 and Duel.GetFlagEffect(tp, id + 6) > 0 and Duel.GetFlagEffect(tp, id + 4) > 0
		and Duel.GetFlagEffect(tp, id + 5) > 0 and Duel.GetFlagEffect(tp, id + 7) > 0 then
		return
	end
	local b1 = Duel.GetFlagEffect(tp, id + 2) == 0
		and Duel.IsExistingMatchingCard(s.monsterfilter, tp, LOCATION_MZONE, 0, 1, nil)

	local b2 = Duel.GetFlagEffect(tp, id + 6) == 0
		and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE, 0, 2, nil)
		and Duel.IsExistingMatchingCard(s.catastrogueaddfilter, tp, LOCATION_DECK, 0, 1, nil)

	local b3 = Duel.GetFlagEffect(tp, id + 4) == 0
		and Duel.IsExistingMatchingCard(s.icemirrorshowfilter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.blizzardfilter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil,
			e, tp)
	local b4 = Duel.GetFlagEffect(tp, id + 5) == 0
		and Duel.IsExistingMatchingCard(s.catastroguetributefilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e,
			tp)

	local b5 = Duel.GetFlagEffect(tp, id + 7) == 0
		and Duel.IsExistingMatchingCard(s.dtunerfilter, tp, LOCATION_HAND, 0, 1, nil)
		and (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4 or b5)
end

function s.flipop2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_CARD, tp, id)
	local b1 = Duel.GetFlagEffect(tp, id + 2) == 0
		and Duel.IsExistingMatchingCard(s.monsterfilter, tp, LOCATION_MZONE, 0, 1, nil)

	local b2 = Duel.GetFlagEffect(tp, id + 6) == 0
		and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE, 0, 2, nil)
		and Duel.IsExistingMatchingCard(s.catastrogueaddfilter, tp, LOCATION_DECK, 0, 1, nil)

	local b3 = Duel.GetFlagEffect(tp, id + 4) == 0
		and Duel.IsExistingMatchingCard(s.icemirrorshowfilter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.blizzardfilter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil,
			e, tp)


	local b4 = Duel.GetFlagEffect(tp, id + 5) == 0
		and Duel.IsExistingMatchingCard(s.catastroguetributefilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e,
			tp)


	local b5 = Duel.GetFlagEffect(tp, id + 7) == 0
		and Duel.IsExistingMatchingCard(s.dtunerfilter, tp, LOCATION_HAND, 0, 1, nil)
		and (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0)

	local op = Duel.SelectEffect(tp, { b1, aux.Stringid(id, 0) },
		{ b2, aux.Stringid(id, 2) },
		{ b3, aux.Stringid(id, 3) },
		{ b4, aux.Stringid(id, 4) },
		{ b5, aux.Stringid(id, 5) })
	op = op - 1

	if op == 0 then
		Duel.RegisterFlagEffect(tp, id + 2, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
	elseif op == 1 then
		Duel.RegisterFlagEffect(tp, id + 6, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
	elseif op == 2 then
		Duel.RegisterFlagEffect(tp, id + 4, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
	elseif op == 3 then
		Duel.RegisterFlagEffect(tp, id + 5, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
	elseif op == 4 then
		local g = Duel.SelectMatchingCard(tp, s.dtunerfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
		if #g > 0 then
			Duel.SendtoDeck(g, tp, SEQ_DECKBOTTOM, REASON_EFFECT)

			local ng = Group.CreateGroup()
			for i, v, remove in ripairs(dtuners) do
				if not v:IsCode(g:GetFirst():GetCode()) then
					Group.AddCard(ng, v)
				end
			end
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
			local sg = ng:Select(tp, 1, 1, nil)
			
			local newcard=Duel.CreateToken(tp, sg:GetFirst():GetCode())
			Duel.SendtoHand(newcard, tp, REASON_RULE)
		end
		Duel.RegisterFlagEffect(tp, id + 7, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
	end
end

-- Once per turn, during each of your Standby Phases, add 1 random Dark Synchro monster, except "Moon Dragon Quilla" and "Hundred Eyes Dragon" to your Extra Deck.

function s.adcon(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.GetTurnPlayer() == tp and not (Duel.GetFlagEffect(tp, id + 3) > 0) then return end



	return Duel.GetTurnPlayer() == tp
end

local table_dsynchro = { 100000151, 100000152, 100000154, 100000155, 81632324 } --og Dark Diviner: 100000156 -- Frozen Fitgerald: 100000155
function s.getcard()
	return table_dsynchro[Duel.GetRandomNumber(1, #table_dsynchro)]
end

function s.adop(e, tp, eg, ep, ev, re, r, rp)
	s.operation_for_res0(e, tp, eg, ep, ev, re, r, rp)
end

function s.operation_for_res0(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_CARD, tp, id)

	local g = Duel.CreateToken(tp, s.getcard())
	Duel.SendtoDeck(g, tp, SEQ_DECKTOP, REASON_EFFECT)
	Duel.RegisterFlagEffect(tp, id + 3, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
end
