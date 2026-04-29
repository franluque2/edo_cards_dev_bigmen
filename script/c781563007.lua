--The Commander's D Pressure
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

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCountLimit(1)
    e1:SetOperation(s.setcard)
    Duel.RegisterEffect(e1, tp)
end

function s.setcard(e, tp, eg, ep, ev, re, r, rp)
    local dtactics=Duel.CreateToken(tp, 48032131)
    Duel.MoveToField(dtactics,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    	local e2=Effect.CreateEffect(dtactics)
		e2:SetDescription(3301)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e2:SetValue(LOCATION_DECKSHF)
		dtactics:RegisterEffect(e2)


end