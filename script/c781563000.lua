--Recycled Power!
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	aux.GlobalCheck(s, function()
		s.used_this_skill = {}
		s.used_this_skill[0] = false
		s.used_this_skill[1] = false

		
		s.used_this_skill_lpgain = {}
		s.used_this_skill_lpgain[0] = false
		s.used_this_skill_lpgain[1] = false
		aux.AddValuesReset(function()
			s.used_this_skill[0] = false
			s.used_this_skill[1] = false

			s.used_this_skill_lpgain[0] = false
			s.used_this_skill_lpgain[1] = false

		end)
	end)


	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		function(e) return (not s.used_this_skill[e:GetHandlerPlayer()]) and aux.CanActivateSkill(e:GetHandlerPlayer()) end, s.flipopactive, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)
end

local roids_to_send = { 73333463, 24311595, 7602840, 44729197, 71218746, 43697559, 25034083, 71930383, 511002894, 61538782, 36378213, 46848859, 99861526, 45945685, 511002234, 18325492 }
local g_roids = {}
g_roids[0] = Group.CreateGroup()
g_roids[1] = Group.CreateGroup()

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	s.fillgroups()
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

	local c = e:GetHandler()
	--VCZ Can summon any Roid
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.vczop)
	Duel.RegisterEffect(e1, tp)

	--Workaround for Edopro Issue: Kiteroid not treated as a roid
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetTargetRange(LOCATION_ALL, 0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsCode, 511000011))
	e3:SetValue(SET_ROID)
	Duel.RegisterEffect(e3, tp)

	--Roids in Deck become Earth
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetTargetRange(LOCATION_DECK, 0)
	e2:SetTarget(s.targfunc)
	e2:SetValue(ATTRIBUTE_EARTH)
	Duel.RegisterEffect(e2, tp)

	--roid multiple mat fusions are unaffected by effects during the bp
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetTargetRange(LOCATION_MZONE, 0)
	e4:SetTarget(function(_, _c)
		 return s.fumultiplematfusionfilter(_c) and Duel.IsBattlePhase() and Duel.IsTurnPlayer(_c:GetControler())
		 end)
	e4:SetValue(1)
	Duel.RegisterEffect(e4, tp)

	local e5 = Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
	e5:SetTargetRange(LOCATION_MZONE, 0)
	e5:SetTarget(function(_, _c) return s.multiplematfusionfilter(_c) end)
	--Duel.RegisterEffect(e5, tp)

	--Once per turn, if a "roid" Fusion Monster you control leaves the field by an opponent's card: You can choose one of them, banish as many of the materials specifically listed on that card as possible from your GY, and if you do, gain LP equal to their combined original ATK, then you can add 1 card from your Deck or GY to your hand that contains an effect to Fusion Summon a monster.
	local e6 = Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCondition(s.leavefieldcon)
	e6:SetOperation(s.leavefieldop)
	Duel.RegisterEffect(e6, tp)




end

function s.leavefieldcon(e, tp, eg, ep, ev, re, r, rp)
	return rp~=tp and eg:IsExists(function(c, _tp) return c:IsPreviousPosition(POS_FACEUP) and s.multiplematfusionfilter(c) and c:GetOwner() == _tp end, 1, nil, tp)
		and Duel.IsExistingMatchingCard(s.banishmatfilter, tp, LOCATION_GRAVE, 0, 1, nil, eg)
		and not s.used_this_skill_lpgain[tp]
end


function s.addtohandfusionfilter(c)
	if not (aux.nvfilter(c) or not c:IsLocation(LOCATION_GRAVE)) then return false end
	if not c:IsAbleToHand() then return end
	local effs={c:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:IsHasCategory(CATEGORY_FUSION_SUMMON) then
			return true
		end
	end
	return false
end

function s.leavefieldop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
		Duel.Hint(HINT_CARD, tp, id)
		s.used_this_skill_lpgain[tp] = true

		local g = Duel.GetMatchingGroup(s.banishmatfilter, tp, LOCATION_GRAVE, 0, nil, eg)
		local total_atk = g:GetSum(Card.GetBaseAttack)
		Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
		Duel.Recover(tp, total_atk, REASON_EFFECT)

		local addg=Duel.GetMatchingGroup(s.addtohandfusionfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, nil)
		if #addg == 0 then return end
			if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
				local tohandg=addg:Select(tp,1,1,nil)
				Duel.SendtoHand(tohandg, nil, REASON_EFFECT)
				Duel.ConfirmCards(1-tp, tohandg)
			end
	end
end
function s.banishmatfilter(c,eg)
	if not eg or #eg == 0 then return false end
	if not c:IsAbleToRemove() then return false end
	for tc in eg:Iter() do
		if s.multiplematfusionfilter(tc) then
			local mat = tc.material
			for _, code in ipairs(mat) do
				if c:IsCode(code) then return true end
			end
		end
	end
	return false
end

function s.multiplematfusionfilter(c)
	return c:IsMonster() and c:IsType(TYPE_FUSION) and c.material and c:IsSetCard(SET_ROID) and #c.material>1
end

function s.fumultiplematfusionfilter(c)
	return s.multiplematfusionfilter(c) and c:IsFaceup()
end

function s.targfunc(e, c)
	return c:IsSetCard(SET_ROID) and c:IsMonster()
end

function s.vczop(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, LOCATION_ALL, nil, 23299957)
	for tc in g:Iter() do
		local eff = tc:GetActivateEffect()
		eff:Reset()
		tc:RegisterEffect(Fusion.CreateSummonEff(tc, s.fusfilter, nil, nil, nil, nil, s.stage2))
	end
end

function s.fusfilter(c, tp)
	return c:IsSetCard(SET_VEHICROID) or (Duel.HasFlagEffect(tp, id) and c:IsSetCard(SET_ROID))
end

function s.stage2(e, tc, tp, sg, chk)
	if chk == 1 then
		local c = e:GetHandler()
		--Cannot be destroyed by card effects
		local e1 = Effect.CreateEffect(c)
		e1:SetDescription(3001)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1, true)
		--Its effects cannot be negated
		local e2 = e1:Clone()
		e2:SetDescription(3308)
		e2:SetCode(EFFECT_CANNOT_DISABLE)
		tc:RegisterEffect(e2, true)
		local e3 = Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(function(e, ct) return Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT):GetHandler() ==
			e:GetHandler() end)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e3, true)
	end
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_CARD, tp, id)

	s.used_this_skill[tp] = true

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Group.Select(g_roids[tp], tp, 4, 4, nil)
	local g2 = Group.CreateGroup()
	for tc in g:Iter() do
		local token = Duel.CreateToken(tp, tc:GetOriginalCode())
		g2:AddCard(token)
	end
	Duel.SendtoGrave(g2, REASON_EFFECT)
end

function s.fillgroups()
	if #g_roids[0] == 0 and #g_roids[1] == 0 then
		for i = 0, 1 do
			for _, card in ipairs(roids_to_send) do
				local token = Duel.CreateToken(i, card)
				g_roids[i]:AddCard(token)
			end
		end
	end
end
