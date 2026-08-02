--Deceiver of the Barians
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

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
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

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1, tp)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetCondition(s.addcardscon)
    e2:SetOperation(s.addcardsop)
    Duel.RegisterEffect(e2, tp)

end

function s.cardfilter(c, tp)
    return c:IsCode(97769122) and c:GetSequence() >= (Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) - (10))
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
    if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
    if #g > 0 then
        Duel.MoveToDeckBottom(g)
    end
end
local CARD_SEVENTH_BARIANS=101402055

function s.rewritecardfilter(c)
    return c:IsCode(CARD_SEVENTH_BARIANS) and c:GetFlagEffect(id)==0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.rewritecardfilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(s.rewritecardfilter, tp, LOCATION_ALL, 0, nil)
    if #g>0 then
        for tc in g:Iter() do
            tc:RegisterFlagEffect(id, 0, 0, 0)
            local eff = { tc:GetCardEffect() }
            for _, teh in ipairs(eff) do
                if teh:GetProperty() & EFFECT_FLAG_PLAYER_TARGET ~= 0 then
                    teh:Reset()
                end
            end

        end
    end
end
local MASQUERADE_VAIN=101402042

local CARDS_TO_ADD={92365601,33725002,13647631,91110378,613013}
function s.addcardscon(e,tp,eg,ep,ev,re,r,rp)
    local oc=re:GetOwner()
    local rc=re:GetHandler()
    return oc and rc and oc:IsCode(MASQUERADE_VAIN) and rc:IsControler(tp) and (rc~=oc) and Duel.CheckLPCost(1-tp, 500)
end

function s.addcardsop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(1-tp, aux.Stringid(id, 0)) then
        
    
    Duel.Hint(HINT_CARD, 1-tp, id)
    Duel.PayLPCost(1-tp, 500)
    for _,card in ipairs(CARDS_TO_ADD) do
        local token=Duel.CreateToken(1-tp, card)
        Duel.SendtoDeck(token, 1-tp, SEQ_DECKBOTTOM, REASON_RULE)
    end
end
end