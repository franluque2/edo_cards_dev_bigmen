--Decree of the Untrue Monarchs
Duel.LoadScript ("big_skill_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1, e2=BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

function s.flipconpassive(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.clearcon)
    e1:SetOperation(s.clearop)
    Duel.RegisterEffect(e1, tp)
end

function s.toclearfilter(c)
    return c:IsOriginalCode(84171830) and c:GetFlagEffect(id)==0
end

function s.clearcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.toclearfilter, tp, LOCATION_ALL, LOCATION_ALL, 1, nil)
end

function s.clearop(e,tp,eg,ep,ev,re,r,rp)

    local g=Duel.GetMatchingGroup(s.toclearfilter, tp, LOCATION_ALL, LOCATION_ALL, nil)
    if #g>0 then
        for tc in g:Iter() do
            if tc:GetFlagEffect(id)==0 then
                tc:RegisterFlagEffect(id, 0, 0, 1)

                local effs={tc:GetOwnEffects()}
                for _,eff in ipairs(effs) do
                    if (eff:GetCode()==EFFECT_CANNOT_SPECIAL_SUMMON) or (eff:GetCode()==CARD_CLOCK_LIZARD) then
                        eff:Reset()
                    end
                end
            end
        end
    end
end

