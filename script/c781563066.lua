--Shackles of Useless Brother
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
        nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local CARD_THUNDER_DRAGON_COLOSSUS=15291624
local CARD_THUNDER_DRAGON_TITAN=41685633

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

    local c = e:GetHandler()

    --rewrite cards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1, tp)
end

function s.rewritecardfilter(c)
    return c:IsOriginalCode(CARD_THUNDER_DRAGON_COLOSSUS,CARD_THUNDER_DRAGON_TITAN) and c:GetFlagEffect(id)==0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.rewritecardfilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(s.rewritecardfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 0)
        if tc:IsOriginalCode(CARD_THUNDER_DRAGON_COLOSSUS) then
            local effs={tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do
                if eff:GetCode()==EFFECT_CANNOT_TO_HAND then
                    eff:Reset()
                end
            end

        elseif tc:IsOriginalCode(CARD_THUNDER_DRAGON_TITAN) then
            local effs={tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do
                if eff:IsHasCategory(CATEGORY_DESTROY) then
                    eff:SetCountLimit(2,id)
                end
            end
        end
    end
end