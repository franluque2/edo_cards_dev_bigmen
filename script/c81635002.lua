--Pay-to-Win
Duel.LoadScript("big_aux.lua")


local s, id = GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c, 2, false, nil, nil)
	local e1 = Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

function s.op(e, tp, eg, ep, ev, re, r, rp)
	if e:GetLabel() == 0 then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1, tp)
	end
	e:SetLabel(1)
end

function s.flipcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetCurrentChain() == 0 and Duel.GetTurnCount() == 1
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	Duel.Hint(HINT_CARD, tp, id)

	--start of duel effects go here

	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(s.flipcon2)
	e1:SetOperation(s.flipop2)
	Duel.RegisterEffect(e1, tp)


	local e2 = Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE + PHASE_DRAW)
	e2:SetCountLimit(1)
	e2:SetCondition(s.flipcon3)
	e2:SetOperation(s.flipop3)
	Duel.RegisterEffect(e2, tp)


	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
end

function s.atohand(code, tp)
	local token = Duel.CreateToken(tp, code)
	Duel.SendtoHand(token, tp, REASON_RULE)
end

function s.atoextra(code, tp)
	local token = Duel.CreateToken(tp, code)
	Duel.SendtoDeck(token, tp, SEQ_DECKTOP, REASON_RULE)
end

function s.flipcon2(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetCurrentChain() == 0 and Duel.GetTurnPlayer() == tp and Duel.GetFlagEffect(tp, id + 1) == 0
end

function s.flipop2(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetFlagEffect(tp, id + 2) > 0 then
		Duel.ResetFlagEffect(tp, id + 2)
	else
		Duel.Hint(HINT_CARD, tp, id)
		--s.atohand(81635003,tp)--credit card
		s.invest(e, tp, eg, ep, ev, re, r, rp)
		Duel.RegisterFlagEffect(tp, id + 2, 0, 0, 0)
	end
	Duel.RegisterFlagEffect(ep, id + 1, RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
end

function s.invest(e, tp, eg, ep, ev, re, r, rp)
	local b1 = Duel.GetFlagEffect(tp, id + 3) == 0
	local b2 = Duel.GetFlagEffect(tp, id + 4) == 0
	local b3 = Duel.GetFlagEffect(tp, id + 5) == 0
	local b4 = Duel.GetFlagEffect(tp, id + 6) == 0

	local op = Duel.SelectEffect(tp, { b1, aux.Stringid(id, 0) },
		{ b2, aux.Stringid(id, 1) },
		{ b3, aux.Stringid(id, 2) },
		{ b4, aux.Stringid(id, 3) })

	if op == 1 then
		Duel.RegisterFlagEffect(tp, id + 3, 0, 0, 0)
	elseif op == 2 then
		Duel.RegisterFlagEffect(tp, id + 4, 0, 0, 0)
	elseif op == 3 then
		Duel.RegisterFlagEffect(tp, id + 5, 0, 0, 0)
	elseif op == 4 then
		Duel.RegisterFlagEffect(tp, id + 6, 0, 0, 0)
	end
end

function s.flipcon3(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetCurrentChain() == 0 and Duel.GetTurnPlayer() == tp and
		(Duel.GetFlagEffect(tp, id + 3) + Duel.GetFlagEffect(tp, id + 4) + Duel.GetFlagEffect(tp, id + 5) + Duel.GetFlagEffect(tp, id + 6)) >
		0
end

function s.iscanrevivefilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.flipop3(e, tp, eg, ep, ev, re, r, rp)

	if Duel.GetFlagEffect(tp, id + 3) > 0 then
		if Duel.GetFlagEffect(tp, id + 3) == 2 then

			Duel.Hint(HINT_CARD, tp, id)


			if Duel.IsExistingMatchingCard(s.iscanrevivefilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil, e, tp) and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
				local card=Duel.SelectMatchingCard(tp, s.iscanrevivefilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
				if card then
					Duel.SpecialSummon(card, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
				end
			end

			Duel.ResetFlagEffect(tp, id + 3)
		else
			Duel.RegisterFlagEffect(tp, id + 3, 0, 0, 0)
		end
	end

	if Duel.GetFlagEffect(tp, id + 4) > 0 then
		if Duel.GetFlagEffect(tp, id + 4) == 3 then

			Duel.Hint(HINT_CARD, tp, id)


			Duel.Draw(tp, 3, REASON_RULE)

			Duel.ResetFlagEffect(tp, id + 4)
		else
			Duel.RegisterFlagEffect(tp, id + 4, 0, 0, 0)
		end
	end

	if Duel.GetFlagEffect(tp, id + 5) > 0 then
		if Duel.GetFlagEffect(tp, id + 5) == 4 then

			Duel.Hint(HINT_CARD, tp, id)


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

			s.atoextra(23995346, tp)
			s.atoextra(23995346, tp)
			s.atoextra(23995346, tp)


			Duel.ResetFlagEffect(tp, id + 5)
		else
			Duel.RegisterFlagEffect(tp, id + 5, 0, 0, 0)
		end
	end

	if Duel.GetFlagEffect(tp, id + 6) > 0 then
		if Duel.GetFlagEffect(tp, id + 6) == 5 then

			Duel.Hint(HINT_CARD, tp, id)


			s.atohand(10000000, tp)

			Duel.ResetFlagEffect(tp, id + 6)
		else
			Duel.RegisterFlagEffect(tp, id + 6, 0, 0, 0)
		end
	end
end
