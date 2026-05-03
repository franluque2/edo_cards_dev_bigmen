--Recycled Power!
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	aux.GlobalCheck(s, function()
		s.used_this_skill = {}
		s.used_this_skill[0] = false
		s.used_this_skill[1] = false
		aux.AddValuesReset(function()
			s.used_this_skill[0] = false
			s.used_this_skill[1] = false
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
	local g = Group.Select(g_roids[tp], tp, 2, 2, nil)
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
