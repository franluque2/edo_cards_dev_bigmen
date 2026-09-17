--Venom of the Serpent Goddess
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)


	aux.GlobalCheck(s,function()

		s.venomminnon_left_field_this_turn={}
		s.venomminnon_left_field_this_turn[0] = false
		s.venomminnon_left_field_this_turn[1] = false




		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_LEAVE_FIELD)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)

		aux.AddValuesReset(function()
			s.venomminnon_left_field_this_turn[0] = false
			s.venomminnon_left_field_this_turn[1] = false
		end)

	end)

end
local CARD_VENOM_SWAMP = 54306223
local CARD_RISE_SNAKE_DEITY = 16067089

local SNAKES_TO_EDIT = {09284723, 36278828, 73899015}

local CARD_VENNOMINAGA = 8062132
local CARD_VENNOMINON = 72677437


function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for ec in aux.Next(eg) do
		if ec:IsPreviousCodeOnField(CARD_VENNOMINON) and not ec:IsReason(REASON_BATTLE)
			and rp==1-ec:GetPreviousControler() then
				s.venomminnon_left_field_this_turn[1-rp] = true
		end
	end
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end


function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()

	s.placecards(e, tp)


	--All monsters you control are treated as "Venom" monsters.
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetTargetRange(LOCATION_MZONE, 0)
	e1:SetValue(SET_VENOM)
	Duel.RegisterEffect(e1, tp)

	--rewrite the 3 snakes

	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetCondition(s.rewritesnakescon)
	e2:SetOperation(s.rewritesnakesop)
	Duel.RegisterEffect(e2, tp)

	--register when a Hyper Venom Counter is placed on your Vennominaga
	--local e3 = Effect.CreateEffect(c)
	--e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	--e3:SetCode(EVENT_ADD_COUNTER+0x11)
	--e3:SetCondition(s.trackhypervenomcountercon)
	--e3:SetOperation(s.trackhypervenomcounterop)
	--Duel.RegisterEffect(e3, tp)

	-- when a vennominaga is summoned, place back venom counters

	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCondition(s.vennominagasummoncon)
	e4:SetOperation(s.vennominagasummonop)
	Duel.RegisterEffect(e4, tp)

	local e5 = e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(e5, tp)

	local e6 = e4:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	Duel.RegisterEffect(e6, tp)
end

local oldfunc= Card.AddCounter
function Card.AddCounter(c, countertype, count, checklimits)
	local ret = oldfunc(c, countertype, count, checklimits)
	if countertype == 0x11 and c:IsCode(CARD_VENNOMINAGA) then
		c:RegisterFlagEffect(id, 0, 0, count)
	end
	return ret
end

function s.rewritesnakesfilter(c)
	return c:IsCode(table.unpack(SNAKES_TO_EDIT)) and c:GetFlagEffect(id)==0
end

function s.rewritesnakescon(e)
	return Duel.IsExistingMatchingCard(s.rewritesnakesfilter, e:GetHandlerPlayer(), LOCATION_ALL, 0, 1, nil)
end

function s.rewritesnakesop(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.GetMatchingGroup(s.rewritesnakesfilter, tp, LOCATION_ALL, 0, nil)
	for tc in g:Iter() do
		tc:RegisterFlagEffect(id, 0, 0, 1)
		local effs={tc:GetOwnEffects()}
		for _, eff in ipairs(effs) do
			if eff:IsHasType(EFFECT_TYPE_IGNITION) then
				local eff2=eff:Clone()
				eff2:SetCode(EVENT_FREE_CHAIN)
				eff2:SetType(EFFECT_TYPE_QUICK_O)
				eff2:SetHintTiming(0, TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_END_PHASE)
				tc:RegisterEffect(eff2)
				eff:Reset()
			end
		end

			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e1:SetType(EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
			e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
			e1:SetCountLimit(1,{tc:GetOriginalCode(),3})
			e1:SetCondition(function () return Duel.IsMainPhase() end)
			e1:SetCost(s.spcost)
			e1:SetTarget(s.sptg)
			e1:SetOperation(s.spop)
			tc:RegisterEffect(e1)

	end
end

function s.placecards(e,tp)

	local token1 = Duel.CreateToken(tp, CARD_VENOM_SWAMP)
	Duel.MoveToField(token1, tp, tp, LOCATION_FZONE, POS_FACEUP, true, 0)

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	e1:SetReset(RESETS_STANDARD)
	e1:SetRange(LOCATION_FZONE)
	token1:RegisterEffect(e1)

	local token2 = Duel.CreateToken(tp, CARD_RISE_SNAKE_DEITY)
	Duel.SSet(tp, token2)

	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	e2:SetReset(RESETS_STANDARD)
	e2:SetRange(LOCATION_SZONE)
	token2:RegisterEffect(e2)

	local token2effs={token2:GetOwnEffects()}
	for _, eff in ipairs(token2effs) do

		if eff:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local eff2=eff:Clone()
			eff2:SetCode(EVENT_FREE_CHAIN)
			eff2:SetHintTiming(0, TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_END_PHASE)
			eff2:SetCondition(s.sptrapcon)

			token2:RegisterEffect(eff2)
			eff:Reset()
		end
	end

	
end

function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated() 
end

function s.sptrapcon(e,tp,eg,ep,ev,re,r,rp)
	return s.venomminnon_left_field_this_turn[tp]
end


function s.spcfilter(c,tp)
	return Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.spcfilter,1,false,nil,nil,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.spcfilter,1,1,false,nil,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--function s.vennominagacounterfilter(c,tp)
--	return c:IsCode(CARD_VENNOMINAGA) and c:IsFaceup() and c:GetControler()==tp and c:GetCounter(0x11)>c:GetFlagEffect(id)
--end
--
--function s.trackhypervenomcountercon(e,tp,eg,ep,ev,re,r,rp)
--  return eg:IsExists(s.vennominagacounterfilter,1,nil,tp)
--end
--
--function s.trackhypervenomcounterop(e,tp,eg,ep,ev,re,r,rp)
--  local g=eg:Filter(s.vennominagacounterfilter,nil,tp)
--  for tc in g:Iter() do
--		local i = tc:GetCounter(0x11)-tc:GetFlagEffect(id)
--		for _ = 1, i, 1 do
--			tc:RegisterFlagEffect(id,0,0,1)
--		end
--  end
--end

function s.summonvenominagafilter(c,tp)
	return c:IsCode(CARD_VENNOMINAGA) and c:IsControler(tp) and c:IsFaceup() and c:GetFlagEffect(id)>0
end

function s.vennominagasummoncon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.summonvenominagafilter,1,nil, tp)
end

function s.vennominagasummonop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.summonvenominagafilter,nil,tp)
	for tc in g:Iter() do
		local num = tc:GetFlagEffect(id)
		tc:ResetFlagEffect(id)
		tc:AddCounter(0x11,num)
	end
end