--King of the Barians
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
    aux.GlobalCheck(s, function()
        s.used_this_skill = {}
        s.used_this_skill[0] = false
        s.used_this_skill[1] = false
    end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,s.flipconactive, s.flipopactive, true, nil)
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

    local e9 = Effect.CreateEffect(e:GetHandler())
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_IMMUNE_EFFECT)
    e9:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e9:SetTargetRange(0, LOCATION_MZONE)
    e9:SetTarget(function(ef, c) return not c:IsOwner(ef:GetHandlerPlayer()) end)
    e9:SetValue(s.efilter2)
    Duel.RegisterEffect(e9, tp)
end

function s.cardfilter(c, tp)
    return c:IsCode(97769122, 57734012) and c:GetSequence() >= (Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) - (10))
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
    if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
    if #g > 0 then
        Duel.MoveToDeckBottom(g)
    end
end

function s.fubarianhopefilter(c)
    return c:IsCode(67926903) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    return (not s.used_this_skill[e:GetHandlerPlayer()]) and aux.CanActivateSkill(e:GetHandlerPlayer()) and
        Duel.IsExistingMatchingCard(s.fubarianhopefilter, tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.atchfilter, tp, LOCATION_EXTRA, 0, 1, nil)
end

function s.atchfilter(c)
    local no = c.xyz_number
    return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER)
        and no and no >= 101 and no <= 107
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    s.used_this_skill[e:GetHandlerPlayer()] = true
    Duel.Hint(HINT_CARD, tp, id)
    Duel.PayLPCost(tp, Duel.GetLP(tp) / 2)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectMatchingCard(tp, s.fubarianhopefilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    local sc = g:GetFirst()
    if sc then
        local g2 = Duel.GetMatchingGroup(s.atchfilter, tp, LOCATION_EXTRA, 0, nil)
        local rg = aux.SelectUnselectGroup(g2, e, tp, 1, 99, aux.dncheck, 1, tp, aux.Stringid(id, 2))
        Duel.Overlay(sc, rg)

        --that barian hope gains the following effects
        --Any Battle Damage your opponent would take from battles involving this card becomes 2000.
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
        e1:SetValue(2000)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        sc:RegisterEffect(e1)

        --This card gains the effect of all "Number C" monsters it has as material.
        local e2 = Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2:SetDescription(aux.Stringid(id, 1))
        e2:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CLIENT_HINT)
        e2:SetCode(EVENT_ADJUST)
        e2:SetRange(LOCATION_MZONE)
        e2:SetOperation(s.operation)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD)
        sc:RegisterEffect(e2)

        Duel.AdjustInstantly(sc, true)
    end
end

function s.filter(c)
    return c:IsMonster() and c:IsSetCard(SET_NUMBER_C)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mats = e:GetHandler():GetOverlayGroup()
    local g = Group.Filter(mats, s.filter, nil)
    g:Remove(s.codefilterchk, nil, e:GetHandler())
    if c:IsFacedown() or #g <= 0 then return end
    repeat
        local tc = g:GetFirst()
        local code = tc:GetOriginalCode()
        local cid = c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD, 1)
        c:RegisterFlagEffect(code, RESET_EVENT + RESETS_STANDARD, 0, 0)
        local e0 = Effect.CreateEffect(c)
        e0:SetCode(id)
        e0:SetLabel(code)
        e0:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(e0, true)
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_ADJUST)
        e1:SetRange(LOCATION_MZONE)
        e1:SetLabel(cid)
        e1:SetLabelObject(e0)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetOperation(s.resetop)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(e1, true)
        g:Remove(s.codefilter, nil, code)
    until #g <= 0
end

function s.codefilter(c, code)
    return c:IsOriginalCode(code)
end

function s.codefilterchk(c, sc)
    return sc:GetFlagEffect(c:GetOriginalCode()) > 0
end

function s.resetop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local mats = e:GetHandler():GetOverlayGroup()
    local g = Group.Filter(mats, s.filter, nil)
    if not g:IsExists(s.codefilter, 1, nil, e:GetLabelObject():GetLabel()) or c:IsDisabled() then
        c:ResetEffect(e:GetLabel(), RESET_COPY)
        c:ResetFlagEffect(e:GetLabelObject():GetLabel())
    end
end

function s.efilter2(e, te)
    return te:GetHandler():IsOriginalCode(34876719)
end
