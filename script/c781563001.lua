--Armed Wings of Darkness
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		nil, nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)
end

local CARD_DARK_ARMED_DRAGON = 65192027
local CARD_DARK_ARMED_ANNHILATION_DRAGON = 78144171

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	s.rewritecards(e, tp)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

	local c = e:GetHandler()



	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetTargetRange(LOCATION_ALL, 0)
	e1:SetTarget(function(_, _c) return _c:IsOriginalCode(CARD_DARK_ARMED_DRAGON) end)
	e1:SetValue(73879377)
	Duel.RegisterEffect(e1, tp)
end

function s.rewritecards(e, tp)
	local c = e:GetHandler()
	local g = Duel.GetMatchingGroup(s.affectedcardfilter, tp, LOCATION_ALL, 0, nil, CARD_DARK_ARMED_DRAGON)
	for tc in g:Iter() do
		local effs = { tc:GetOwnEffects() }
		for _, eff in ipairs(effs) do

			if (eff:GetCode() == EFFECT_SPSUMMON_CONDITION) or (eff:GetCode() == EFFECT_SPSUMMON_PROC) or (eff:GetCode() == EFFECT_TYPE_IGNITION) then
				eff:Reset()
			end
		end
		tc:RegisterFlagEffect(id, 0, 0, 1)

		local e1 = Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_SPSUMMON_CONDITION)
		e1:SetValue(function(e,sum_eff) return sum_eff:GetHandler():IsSetCard(SET_ARMED_DRAGON) and sumeff:GetHandler():IsMonster() end)
		tc:RegisterEffect(e1)
		--special summon
		local e2 = Effect.CreateEffect(tc)
		e2:SetDescription(aux.Stringid(id, 1))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_SPSUMMON_PROC)
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e2:SetRange(LOCATION_HAND)
		e2:SetCondition(s.spcon)
		tc:RegisterEffect(e2)
		--destroy
		local e3 = Effect.CreateEffect(tc)
		e3:SetDescription(aux.Stringid(id, 2))
		e3:SetCategory(CATEGORY_DESTROY)
		e3:SetType(EFFECT_TYPE_IGNITION)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCost(s.cost)
		e3:SetTarget(s.target)
		e3:SetOperation(s.activate)
		tc:RegisterEffect(e3)

		local metatable = tc:GetMetatable()
		if metatable.listed_series and #metatable.listed_series > 0 then
			table.insert(metatable.listed_series, SET_ARMED_DRAGON)
		else
			metatable.listed_series = { SET_ARMED_DRAGON }
		end
	end
	local g2 = Duel.GetMatchingGroup(s.affectedcardfilter, tp, LOCATION_ALL, 0, nil, CARD_DARK_ARMED_ANNHILATION_DRAGON)
	for tc in g2:Iter() do
		local effs = { tc:GetOwnEffects() }
		for _, eff in ipairs(effs) do
			if eff:GetCode() == EFFECT_SPSUMMON_PROC then
				eff:Reset()
			end
		end
		tc:RegisterFlagEffect(id, 0, 0, 1)

			Xyz.AddProcedure(tc,nil,7,2,s.ovfilter,aux.Stringid(CARD_DARK_ARMED_ANNHILATION_DRAGON,0),Xyz.InfiniteMats,s.xyzop)


	end
end

function s.affectedcardfilter(c, code)
	return c:IsCode(code) and not c:HasFlagEffect(id)
end

function s.spcon(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.GetMatchingGroupCount(s.spfilterfunc, c:GetControler(), LOCATION_GRAVE, 0, nil) == 3
end

function s.spfilterfunc(c)
	return c:IsAttribute(ATTRIBUTE_DARK) or (c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_DRAGON))
end

function s.costfilter(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) or (c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_DRAGON))) and
	c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c, true)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_MZONE|LOCATION_GRAVE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_MZONE|LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsOnField() end
	if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc, REASON_EFFECT)
	end
end



function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON,lc,SUMMON_TYPE_XYZ,tp) and c:IsAttribute(ATTRIBUTE_DARK,lc,SUMMON_TYPE_XYZ,tp) and c:IsLevelAbove(5)
		and Duel.GetMatchingGroupCount(s.spfilterfunc,tp,LOCATION_GRAVE,0,nil)==5
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,CARD_DARK_ARMED_ANNHILATION_DRAGON)==0 end
	Duel.RegisterFlagEffect(tp,CARD_DARK_ARMED_ANNHILATION_DRAGON,RESET_PHASE|PHASE_END,0,1)
	return true
end