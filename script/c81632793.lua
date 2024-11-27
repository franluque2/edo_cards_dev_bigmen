--Golondrinas Jail (CT)
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    --Continuous effect: Reduce ATK of face-up LIGHT monsters
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.atktarget)
    e2:SetValue(s.atkvalue)
    c:RegisterEffect(e2)
end

--Target: Face-up LIGHT Attribute monsters
function s.atktarget(e,c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end

--Value: Decrease ATK by [total number of LIGHT monsters in both players' Graveyards] x 100
function s.atkvalue(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,ATTRIBUTE_LIGHT)
    return -g:GetCount() * 100
end


