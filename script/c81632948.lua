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

		local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATION_DECK,0)
        e5:SetTarget(aux.TargetBoolFunction(Card.IsOriginalSetCard, 0x600))
        e5:SetValue(0x1017)
        Duel.RegisterEffect(e5,tp)

		local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_RACE)
        e6:SetTargetRange(LOCATION_GRAVE,0)
        e6:SetTarget(function(_,c)  return c:IsSetCard(0x600) or c:IsSetCard(0x601) end)
		e6:SetCondition(s.changcon)
        e6:SetValue(RACE_MACHINE)
        Duel.RegisterEffect(e6,tp)
		

		local e7=e6:Clone()
		e7:SetCode(EFFECT_CHANGE_LEVEL)
		e7:SetValue(8)
		Duel.RegisterEffect(e7, tp)
	end
	e:SetLabel(1)
end



function s.changcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(s.fudarkflattopfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.fudarkflattopfilter(c)
	return c:IsFaceup() and c:IsCode(67904682)
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
dtuners[0]=Group.CreateGroup()
dtuners[1]=Group.CreateGroup()

local dtunerstoadd = { 81632644, 81632645, 81632646, 81632647, 81632648, 81632649, 81632650 }

function s.generatedtuners(e, tp, eg, ep, ev, re, r, rp)
	if #dtuners[0]~=0 then
		return
	end
	for key, value in ipairs(dtunerstoadd) do
		local newcard = Duel.CreateToken(0, value)
		dtuners[0]:AddCard(newcard)

		local newcard2 = Duel.CreateToken(1, value)
		dtuners[1]:AddCard(newcard2)
	end
end


function s.blizzardfilter(c)
	return c:IsCode(100000157)
		and c:IsAbleToHand()
end

function s.spsumdtunerfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(0x600) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false, POS_FACEUP)
end


function s.dtunerfilter(c)
	return c:IsSetCard(0x600) and not c:IsPublic() and c:IsAbleToDeck()
end

function s.addwaterfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(3)
end

function s.darkmirrorshufflefilter(c)
	return c:IsCode(69492187) and c:IsAbleToDeck()
end

function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==1
end

function s.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToDeck()
end
function s.flipcon2(e, tp, eg, ep, ev, re, r, rp)

	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil)

	--OPT check
	if Duel.GetFlagEffect(tp, id + 2) > 0 and Duel.GetFlagEffect(tp, id + 6) > 0 and Duel.GetFlagEffect(tp, id + 4) > 0
		and Duel.GetFlagEffect(tp, id + 5) > 0 then
		return
	end
	local b1 = Duel.GetFlagEffect(tp, id + 2) == 0
	 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.addwaterfilter, tp, LOCATION_DECK, 0, 1, nil)

	local b2 = Duel.GetFlagEffect(tp, id + 6) == 0
		and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE, 0, 2, nil)
		and Duel.IsExistingMatchingCard(s.spsumdtunerfilter, tp, LOCATION_HAND, 0, 1, nil,e,tp)

	local b3 = Duel.GetFlagEffect(tp, id + 4) == 0
		and Duel.IsExistingMatchingCard(s.dtunerfilter, tp, LOCATION_HAND, 0, 1, nil)

	local b4 = Duel.GetFlagEffect(tp, id + 5) == 0
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,0)
		and Duel.IsExistingMatchingCard(s.darkmirrorshufflefilter, tp, LOCATION_GRAVE, 0, 1, nil)

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
end

function s.notcardiscode(c, code)
	return not c:IsCode(code)
end

function s.flipop2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_CARD, tp, id)
	local g3=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil)

	local b1 = Duel.GetFlagEffect(tp, id + 2) == 0
	 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.addwaterfilter, tp, LOCATION_DECK, 0, 1, nil)

	local b2 = Duel.GetFlagEffect(tp, id + 6) == 0
		and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE, 0, 2, nil)
		and Duel.IsExistingMatchingCard(s.spsumdtunerfilter, tp, LOCATION_HAND, 0, 1, nil,e,tp)

	local b3 = Duel.GetFlagEffect(tp, id + 4) == 0
		and Duel.IsExistingMatchingCard(s.dtunerfilter, tp, LOCATION_HAND, 0, 1, nil)

	local b4 = Duel.GetFlagEffect(tp, id + 5) == 0
		and aux.SelectUnselectGroup(g3,e,tp,2,2,s.spcheck,0)
		and Duel.IsExistingMatchingCard(s.darkmirrorshufflefilter, tp, LOCATION_GRAVE, 0, 1, nil)


	local op = Duel.SelectEffect(tp, { b1, aux.Stringid(id, 0) },
		{ b2, aux.Stringid(id, 1) },
		{ b3, aux.Stringid(id, 2) },
		{ b4, aux.Stringid(id, 3) })
	op = op - 1

	if op == 0 then
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)

		local tc=Duel.SelectMatchingCard(tp, s.addwaterfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
		if tc then
			Duel.SendtoHand(tc, tp, REASON_RULE)
			Duel.ConfirmCards(1-tp, tc)
		end

		Duel.RegisterFlagEffect(tp, id + 2, 0, 0, 0)
	elseif op == 1 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)

		local tc=Duel.SelectMatchingCard(tp, s.spsumdtunerfilter, tp, LOCATION_HAND, 0, 1,1,false,nil,e,tp)
		if tc then
			Duel.SpecialSummon(tc, 0, tp, tp, false,false,POS_FACEUP)
		end

		Duel.RegisterFlagEffect(tp, id + 6, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
	elseif op == 2 then
		
		local g = Duel.SelectMatchingCard(tp, s.dtunerfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
		if #g > 0 then
			Duel.SendtoDeck(g, tp, SEQ_DECKBOTTOM, REASON_EFFECT)

			local ng = Group.Filter(dtuners[tp], s.notcardiscode, nil, g:GetFirst():GetCode())
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
			local sg = ng:Select(tp, 1, 1, nil)
			
			local newcard=Duel.CreateToken(tp, sg:GetFirst():GetCode())
			Duel.SendtoHand(newcard, tp, REASON_RULE)
		end
		Duel.RegisterFlagEffect(tp, id + 4, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
	elseif op == 3 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp, s.darkmirrorshufflefilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil)
		local g2=aux.SelectUnselectGroup(g3,e,tp,2,2,s.spcheck,1, tp, HINTMSG_TODECK, nil, nil, false)

		Group.Merge(g, g2)

		if Duel.SendtoDeck(g, tp,SEQ_DECKSHUFFLE, REASON_RULE) and Duel.IsExistingMatchingCard(s.blizzardfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)

			local tc=Duel.SelectMatchingCard(tp, s.blizzardfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1,1,false,nil)
			if tc then
				Duel.SendtoHand(tc, tp, REASON_RULE)
				Duel.ConfirmCards(1-tp, tc)
			end
	
		end

		Duel.RegisterFlagEffect(tp, id + 5, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
	end
end

-- Once per turn, during each of your Standby Phases, add 1 random Dark Synchro monster, except "Moon Dragon Quilla" and "Hundred Eyes Dragon" to your Extra Deck.

function s.adcon(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.GetTurnPlayer() == tp and not (Duel.GetFlagEffect(tp, id + 3) > 0) then return end



	return Duel.GetTurnPlayer() == tp
end

local table_dsynchro = { 100000151, 100000152, 100000154, 81632324 } --og Dark Diviner: 100000156 -- Frozen Fitgerald: 100000155
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
