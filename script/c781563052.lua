--Shackles of a Sadistic Alterego
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

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
        e2:SetTargetRange(0,LOCATION_MZONE)
        e2:SetTarget(function(ef,c) return not (c:HasCounter(COUNTER_PREDATOR)) end)
        e2:SetValue(s.sumlimit)
        Duel.RegisterEffect(e2,tp)

            local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_ADJUST)
    e0:SetCondition(s.rewritedharedevilcon)
    e0:SetOperation(s.rewritedharedevilop)
    Duel.RegisterEffect(e0,tp)
end


function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end

local CARD_PREDAPLANT_DHAREDEIL=82370493

function s.nottaggeddharedevilfilter(c)
    return c:IsCode(CARD_PREDAPLANT_DHAREDEIL) and c:GetFlagEffect(id)==0
end

function s.rewritedharedevilcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.nottaggeddharedevilfilter,tp,LOCATION_ALL,0,1,nil)
end

function s.rewritedharedevilop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.nottaggeddharedevilfilter,tp,LOCATION_ALL,0,nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id,0,0,1)
        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if eff:GetDescription()==aux.Stringid(CARD_PREDAPLANT_DHAREDEIL,0) then
                eff:Reset()
            end
        end
    end
end