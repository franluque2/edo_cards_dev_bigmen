--War To Zen! The Galactical Road!
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
	aux.AddSkillProcedure(c, 2, false, s.flipcon2, s.flipop2)

	aux.GlobalCheck(s, function()
		--register
		local ge1 = Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DRAW)
		ge1:SetOperation(s.op2)
		Duel.RegisterEffect(ge1, 0)
	end)
end

function s.op2(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.GetCurrentPhase() == PHASE_DRAW then return end
	if not (Duel.GetTurnCount()>1) then return end
	local g = eg
	local tc = g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
		tc = g:GetNext()
	end
end

function s.op(e, tp, eg, ep, ev, re, r, rp)
	if e:GetLabel() == 0 then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1, tp)

		--other passive duel effects go here

		--uncomment (remove the --) the line below to make it a rush skill
		bRush.addrules()(e, tp, eg, ep, ev, re, r, rp)

		local c = e:GetHandler()
		local e2 = Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE + PHASE_STANDBY)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2, tp)


		local e3 = Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e3:SetCountLimit(1)
		e3:SetCode(EVENT_PHASE + PHASE_END)
		e3:SetCondition(s.setcon)
		e3:SetOperation(s.setop)
		Duel.RegisterEffect(e3, tp)

		local e4 = Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e4:SetCountLimit(1)
		e4:SetCode(EVENT_PHASE + PHASE_END)
		e4:SetCondition(s.setcon2)
		e4:SetOperation(s.setop2)
		Duel.RegisterEffect(e4, tp)

		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PREDRAW)
		e5:SetCondition(s.stackcon)
		e5:SetOperation(s.stackop)
		Duel.RegisterEffect(e5,tp)
	end
	e:SetLabel(1)
end


function s.abletoaddpiece(c,code)
    return c:IsCode(code) and c:IsAbleToHand()
end

function s.otherpiecefinder(c,code)
    return math.abs(c:GetCode()-code)<4 and not c:IsCode(code)
end

function s.abletopiece(c)
    if not c:IsType(TYPE_MAXIMUM) then return false end

    local g=Duel.GetMatchingGroup(s.otherpiecefinder, c:GetOwner(), LOCATION_DECK, 0, nil, c:GetCode())
    if g:GetClassCount(Card.GetCode)<2 then return false end

    return true
end

function s.ablereviece(c)
    if not c:IsType(TYPE_MAXIMUM) then return false end

    local g=Duel.GetMatchingGroup(s.otherpiecefinder, c:GetOwner(), LOCATION_HAND, 0, nil, c:GetCode())
    if g:GetClassCount(Card.GetCode)<2 then return false end

    return not c:IsPublic()
end

function s.stackcon(e,tp,eg,ep,ev,re,r,rp)
    if not ( Duel.GetTurnCount()>2 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+4)==0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<3) then return false end
    local g=Duel.GetDecktopGroup(tp, 5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0))
    if g:IsExists(s.abletopiece, 1, nil) then return true end
    return false
end
function s.stackop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 7)) then
        local tc=Duel.GetFirstMatchingCard(s.abletopiece, tp, LOCATION_DECK, 0, nil)
        local pieces=Duel.GetMatchingGroup(s.otherpiecefinder, tp, LOCATION_DECK, 0, nil, tc:GetCode())
        local tc2=pieces:GetFirst()
        local filteredpieces=pieces:Filter(s.otherpiecefinder, nil, tc2:GetCode())
        local tc3=filteredpieces:GetFirst()
        Duel.DisableShuffleCheck()

        Duel.MoveSequence(tc2,0 )
        Duel.MoveSequence(tc,0 )
        Duel.MoveSequence(tc3, 0)

        Duel.DisableShuffleCheck(false)

        Duel.RegisterFlagEffect(tp, id+4, 0, 0, 0)
    end
end


function s.setcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetCurrentChain() == 0 and Duel.GetTurnPlayer() == tp and
		Duel.IsExistingMatchingCard(s.futransamufilter, tp, LOCATION_ONFIELD, 0, 1, nil) and
		Duel.IsExistingMatchingCard(s.transamuspelltrapfilter, tp, LOCATION_GRAVE, 0, 1, nil) and
		Duel.GetLocationCount(tp, LOCATION_SZONE - LOCATION_FZONE) > 0
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
		Duel.Hint(HINT_CARD, tp, id)

		local tar = Duel.SelectMatchingCard(tp, s.transamuspelltrapfilter, tp, LOCATION_GRAVE, 0, 1, 1, false, nil)
		if tar then
			Duel.SSet(tp, tar)
			Duel.ConfirmCards(1 - tp, tar)

			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3300)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tar:GetFirst():RegisterEffect(e1, true)
		end
	end
end

function s.setcon2(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetCurrentChain() == 0 and Duel.GetTurnPlayer() == tp and
		Duel.IsExistingMatchingCard(s.galacticafilter, tp, LOCATION_ONFIELD, 0, 1, nil) and
		Duel.IsExistingMatchingCard(s.galacticaspelltrapfilter, tp, LOCATION_GRAVE, 0, 1, nil) and
		Duel.GetLocationCount(tp, LOCATION_SZONE - LOCATION_FZONE) > 0
end

function s.setop2(e, tp, eg, ep, ev, re, r, rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
		Duel.Hint(HINT_CARD, tp, id)

		local tar = Duel.SelectMatchingCard(tp, s.galacticaspelltrapfilter, tp, LOCATION_GRAVE, 0, 1, 1, false, nil)
		if tar then
			Duel.SSet(tp, tar)
			Duel.ConfirmCards(1 - tp, tar)

			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3300)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT + RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tar:GetFirst():RegisterEffect(e1, true)
		end
	end
end

function s.drewthisturnfilter(c)
	return c:GetFlagEffect(id) > 0 and c:IsAbleToDeck()
end

function s.addtransamufilter(c)
	return c:IsCode(CARD_TRANSAMU_RAINAC) and c:IsAbleToHand()
end

function s.adcon(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.GetTurnPlayer() == tp and not (Duel.GetFlagEffect(tp, id + 3) > 0) then return end

	local b1 = Duel.GetFlagEffect(tp, id + 3) == 0
		and Duel.IsExistingMatchingCard(s.drewthisturnfilter, tp, LOCATION_HAND, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.addtransamufilter, tp, LOCATION_DECK, 0, 1, nil)


	return Duel.GetTurnPlayer() == tp and (b1)
end

function s.adop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		Duel.Hint(HINT_CARD, tp, id)

		local g = Duel.SelectMatchingCard(tp, s.drewthisturnfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
		if #g > 0 then
			Duel.ConfirmCards(1 - tp, g)
			Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_RULE)
			local transamu = Duel.GetFirstMatchingCard(s.addtransamufilter, tp, LOCATION_DECK, 0, nil)
			if transamu then
				Duel.SendtoHand(transamu, tp, REASON_RULE)
				Duel.ConfirmCards(1 - tp, transamu)
			end
		end
		Duel.RegisterFlagEffect(tp, id + 3, 0, 0, 0)
	end
end

function s.flipcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetCurrentChain() == 0 and Duel.GetTurnCount() == 1
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	Duel.Hint(HINT_CARD, tp, id)

	s.addfusionprocedures(e, tp, eg, ep, ev, re, r, rp)



	--start of duel effects go here
	Duel.RegisterFlagEffect(ep, id, 0, 0, 0)
end

function s.lowlevelgalacfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsLevelBelow(4) + c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.highlevelgalacfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsLevelAbove(7) + c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.addfusionprocedures(e, tp, eg, ep, ev, re, r, rp)
	local g1=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 160015036)
	for tc in g1:Iter() do
		Fusion.AddProcMix(tc,true,true,160009002,aux.FilterBoolFunctionEx(s.lowlevelgalacfilter))
	end

	local g2=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 160012030)
	for tc in g2:Iter() do
		Fusion.AddProcMix(tc,true,true,CARD_TRANSAMU_RAINAC,aux.FilterBoolFunctionEx(s.highlevelgalacfilter))
	end
end

function s.futransamufilter(c)
	return c:IsCode(CARD_TRANSAMU_RAINAC) and c:IsFaceup()
end

function s.highlevelfilter(c)
	return c:IsLevelAbove(7) and c:IsFaceup() and not c:IsCode(CARD_SEVENS_ROAD_MAGICIAN)
end

function s.galacticafilter(c)
	return c:IsCode(160009002) and c:IsFaceup()
end

function s.transamuspelltrapfilter(c)
	return c:IsCode(160012056, 160311028) and c:IsSSetable()
end

function s.galacticaspelltrapfilter(c)
	return c:IsCode(160311022, 160313024, 160011040, 160313030) and c:IsSSetable()
end

function s.specialsummongalaxyfilter(c, e, tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_GALAXY) and
	c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

--effects to activate during the main phase go here
function s.flipcon2(e, tp, eg, ep, ev, re, r, rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp, id + 2) > 0 then return end
	--Boolean checks for the activation condition: b1, b2

	--do bx for the conditions for each effect, and at the end add them to the return
	--local b1 = Duel.GetFlagEffect(tp, id + 1) == 0
	--	and Duel.IsExistingMatchingCard(s.futransamufilter, tp, LOCATION_ONFIELD, 0, 1, nil)
	--	and Duel.IsExistingMatchingCard(s.highlevelfilter, tp, LOCATION_MZONE, 0, 1, nil)

	local b2 = Duel.GetFlagEffect(tp, id + 2) == 0
		and Duel.IsExistingMatchingCard(s.galacticafilter, tp, LOCATION_MZONE, 0, 1, nil, tp)
		and Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, nil) == 1
		and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 2


	--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b2)
end

function s.flipop2(e, tp, eg, ep, ev, re, r, rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD, tp, id)
	--Boolean check for effect 1:

	--copy the bxs from above

	--local b1 = Duel.GetFlagEffect(tp, id + 1) == 0
	--	and Duel.IsExistingMatchingCard(s.futransamufilter, tp, LOCATION_ONFIELD, 0, 1, nil)
	--	and Duel.IsExistingMatchingCard(s.highlevelfilter, tp, LOCATION_MZONE, 0, 1, nil)

		local b2 = Duel.GetFlagEffect(tp, id + 2) == 0
		and Duel.IsExistingMatchingCard(s.galacticafilter, tp, LOCATION_MZONE, 0, 1, nil, tp)
		and Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, nil) == 1
		and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 2

	--effect selector
	local op = Duel.SelectEffect(tp,
		{ b2, aux.Stringid(id, 2) })
	op = op - 1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op == 0 then
		s.operation_for_res0(e, tp, eg, ep, ev, re, r, rp)
	elseif op == 1 then
		s.operation_for_res1(e, tp, eg, ep, ev, re, r, rp)
	end
end

function s.operation_for_res0(e, tp, eg, ep, ev, re, r, rp)
	local tar = Duel.SelectMatchingCard(tp, s.highlevelfilter, tp, LOCATION_MZONE, 0, 1, 1, false, nil)
	if tar then
		local op = Duel.SelectEffect(tp, { true, aux.Stringid(id, 5) },
		{ true, aux.Stringid(id, 6) })
		local cardid
		if op==1 then
			cardid=CARD_SEVENS_ROAD_MAGICIAN
		else
			cardid=160015003
		end

		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		e1:SetValue(cardid)
		tar:GetFirst():RegisterEffect(e1)
	end


	--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp, id + 1, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
end

function s.operation_for_res1(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetDecktopGroup(tp, 3)
	Duel.ConfirmDecktop(tp, 3)

	local g2 = g:Filter(s.specialsummongalaxyfilter, nil, e, tp)
	if #g2 > 0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local sum = g2:Select(tp, 0, 1, nil)

		if #sum > 0 then
			Duel.SpecialSummon(sum, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
			g = g:RemoveCard(sum)
		end
	end

	Duel.SendtoGrave(g, REASON_EFFECT)


	--sets the opd
	Duel.RegisterFlagEffect(tp, id + 2, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
end
