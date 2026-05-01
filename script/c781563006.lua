--Shackles of an Unfortunate Actor
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
        nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

    local c = e:GetHandler()

    local CARD_RISE_ABYSS_KING = 13662809

    --after resolving rise of the abyss king, add 2 random action cards to the opp hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVED)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return re and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsCode(CARD_RISE_ABYSS_KING) and rp==tp
    end)
    e1:SetOperation(s.addactioncards)
    Duel.RegisterEffect(e1, tp)


    local e6 = Effect.GlobalEffect()
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_IGNORE_RANGE +
        EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SET_AVAILABLE)
    e6:SetCode(EFFECT_BECOME_QUICK)
    e6:SetTargetRange(0, 0xff)
    e6:SetTarget(aux.TargetBoolFunction(Card.IsType, TYPE_ACTION))
    Duel.RegisterEffect(e6, tp)
    local e7 = e6:Clone()
    e7:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    Duel.RegisterEffect(e7, tp)
    local e8 = e6:Clone()
    e8:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
    Duel.RegisterEffect(e8, tp)

    local e9 = Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e9:SetCode(EVENT_TURN_END)
    e9:SetCountLimit(1)
    e9:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(tp) end)
    e9:SetOperation(s.removeactioncards)
    Duel.RegisterEffect(e9, tp)
end

local actioncards = { 150000020, 150000024 }

function s.addactioncards(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, tp, id)
    local g = Group.CreateGroup()
    for i = 1, 2, 1 do
        local ac = actioncards[math.random(#actioncards)]
        local tc = Duel.CreateToken(1 - tp, ac)
        tc:RegisterFlagEffect(id, 0, 0, 0, tp)
        g:AddCard(tc)
    end
    Duel.SendtoHand(g, nil, REASON_RULE)
    Duel.ConfirmCards(tp, g)
end

function s.remfilter(c)
    return c:IsType(TYPE_ACTION) and c:IsSpell() and c:GetFlagEffect(id) > 0
end

function s.removeactioncards(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.remfilter, tp, 0, LOCATION_ALL, nil)
    Duel.RemoveCards(g)
end
