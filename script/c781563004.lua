--Shackles of a Ferromagnetic Scholar
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
    s.rewritecards(e, tp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

    local c = e:GetHandler()
end

function s.rewritecards(e, tp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ALL, 0, nil, 47247792)

    if #g > 0 then
        for tc in g:Iter() do
            if tc:GetFlagEffect(id) == 0 then
                local eff = { tc:GetCardEffect() }
                for _, teh in ipairs(eff) do
                    if teh:GetCode() & EFFECT_CHANGE_ATTRIBUTE == EFFECT_CHANGE_ATTRIBUTE then
                        teh:Reset()
                    end
                end
                tc:RegisterFlagEffect(id, 0, 0, 0)

                local e1 = Effect.CreateEffect(tc)
                e1:SetType(EFFECT_TYPE_FIELD)
                e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
                e1:SetRange(LOCATION_MZONE)
                e1:SetTargetRange(LOCATION_MZONE, 0)
                e1:SetValue(ATTRIBUTE_EARTH)
                tc:RegisterEffect(e1)

                local e2 = e1:Clone()
                e2:SetCode(EFFECT_ADD_ATTRIBUTE)
                e2:SetTargetRange(0, LOCATION_MZONE)
                tc:RegisterEffect(e2)
            end
        end
    end
end
