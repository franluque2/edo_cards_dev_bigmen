--Dregs of Angra Mainyu
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_SSET)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(tp,1000,REASON_EFFECT)
end
