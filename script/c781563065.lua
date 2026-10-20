--Grand Spiritual Art - Second Cycle
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_STARTUP)
	e3:SetRange(0x5f)
	e3:SetCountLimit(1)
	e3:SetOperation(s.shuffledownop)
	c:RegisterEffect(e3)

	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, s.flipconactive, s.flipopactive, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

    	aux.GlobalCheck(s, function()
		s.used_this_skill = {}
		s.used_this_skill[0] = false
		s.used_this_skill[1] = false

        s.used_this_skill1 = {}
		s.used_this_skill1[0] = false
		s.used_this_skill1[1] = false
		aux.AddValuesReset(function()
			--s.used_this_skill[0] = false
			--s.used_this_skill[1] = false
			s.used_this_skill1[0] = false
			s.used_this_skill1[1] = false
		end)
	end)
end

local blacklisted_cards={410904,65268179,92652813,759394,19327349,37744403,37970941,73318864,74364660,4376659,21390858,31764353,31887905,68881650,40542826,38167722,79333300,70156997,42945701,5037726,98385955,3496543,65046521,25704359,61082944,
                        00759393, 19327348, 37744402, 37970940, 73318863, 74364659, 04376658, 21390858, 31764353, 31887905, 68881649, 40542825}



function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()

	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetOperation(s.shuffledownop)
	e1:SetCountLimit(1)
	Duel.RegisterEffect(e1, tp)
end

function s.cardfilter(c, tp)
	return c:IsCode(table.unpack(blacklisted_cards)) and
	c:GetSequence() >= (Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) - (30))
end



function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
	if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
	if #g > 0 then
		Duel.MoveToDeckBottom(g)
	end
end

local oldfunc = Duel.Draw

Duel.Draw = function(tp, num, reason)
	if Duel.GetFlagEffect(tp, id) > 0 then
		s.shuffledownop(nil, tp)
	end
	return oldfunc(tp, num, reason)
end

function s.shufflefilter(c)
    return c:IsAbleToDeckAsCost() and not c:IsForbidden()
end

function s.addfilter(c)
    return c:IsAbleToHand() and ((c:IsRace(RACE_SPELLCASTER) and c:IsMonster()) or c:IsSetCard(SET_POSSESSED) or c:IsSetCard(SET_SPELLBOOK))
end

function s.flipfilter(c)
    return c:IsFacedown() and c:IsMonster() and c:IsCanChangePosition()
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    local b1= not s.used_this_skill[e:GetHandlerPlayer()] and (Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_MZONE, nil)>0) and
                 Duel.IsExistingMatchingCard(s.shufflefilter, tp, LOCATION_HAND, 0, 1, nil) and Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 1, nil)
    local b2= not s.used_this_skill1[e:GetHandlerPlayer()] and Duel.CheckLPCost(tp, 1600) and Duel.IsExistingMatchingCard(s.flipfilter, tp, LOCATION_MZONE, 0, 1, nil)
    return (b1 or b2) and aux.CanActivateSkill(tp)
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    local b1= not s.used_this_skill[e:GetHandlerPlayer()] and (Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_MZONE, nil)>0) and
                 Duel.IsExistingMatchingCard(s.shufflefilter, tp, LOCATION_HAND, 0, 1, nil) and Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 1, nil)
    local b2= not s.used_this_skill1[e:GetHandlerPlayer()] and Duel.CheckLPCost(tp, 1600) and Duel.IsExistingMatchingCard(s.flipfilter, tp, LOCATION_MZONE, 0, 1, nil)

    local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									{b2,aux.Stringid(id,1)})

    Duel.Hint(HINT_CARD,tp,id)
    
    if op==1 then
        s.used_this_skill[e:GetHandlerPlayer()] = true
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
        local g = Duel.SelectMatchingCard(tp, s.shufflefilter, tp, LOCATION_HAND, 0, 1, 1, nil)
        if #g > 0 then
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
        end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local sg = Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #sg > 0 then
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1-tp, sg)
        end
    elseif op==2 then
        s.used_this_skill1[e:GetHandlerPlayer()] = true
        Duel.PayLPCost(tp, 1600)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
        local g = Duel.SelectMatchingCard(tp, s.flipfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
        if #g > 0 then
            Duel.ChangePosition(g, POS_FACEUP_DEFENSE)
        end
    end
end