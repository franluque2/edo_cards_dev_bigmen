--Watchers of the Clock Tower City
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end



function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

local DHEROES_TO_PLACE={81866673,28355718,13093792,93431862,80744121,54749427,77608643,41613948,36625827,55461064,39829561,56570271}

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    for _, code in ipairs(DHEROES_TO_PLACE) do
        local token=Duel.CreateToken(tp, code)
        Duel.SendtoGrave(token, REASON_RULE)

        local e1=Effect.CreateEffect(c)
        e1:SetDescription(3302)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_TRIGGER)
        e1:SetReset(RESETS_STANDARD_PHASE_END)
        token:RegisterEffect(e1)
    end

    --Negate the effects of all face-up "Destiny HERO - Plasma" and "Destiny HERO - Dogma" you control.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsCode, 83965310,17132130))
    Duel.RegisterEffect(e1,tp)

        local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
    e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e6:SetTargetRange(LOCATION_MZONE,0)
    e6:SetTarget(s.efilter)
    e6:SetValue(1)
    Duel.RegisterEffect(e6, tp)

        local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetCondition(s.rewritecardscon)
    e2:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e2, tp)
end


function s.efilter(e,c)
	return c:IsCode(40591390,101402037) -- TODO: change 101402037 id to real id when dreadnought is released
end



function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.torewritefilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.torewritefilter(c)
    return c:IsOriginalCode(60461804) and c:IsOriginalType(TYPE_MONSTER) and c:GetFlagEffect(id) == 0
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.torewritefilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)
        local effs={tc:GetOwnEffects()}

        for _, eff in ipairs(effs) do
            if (eff:GetType()&EFFECT_TYPE_FIELD)==EFFECT_TYPE_FIELD and (eff:GetCode()&EFFECT_UPDATE_ATTACK)==EFFECT_UPDATE_ATTACK then
                eff:Reset()
            end
        end
    end
end