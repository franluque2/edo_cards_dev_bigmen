--Golondrinas Jail (CT)
local s,id=GetID()
function s.initial_effect(c)
    --Field Spell activation
    aux.AddFieldSpellEffect(c)
    
    --Reduce ATK of LIGHT Attribute monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(s.atktg)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
end

--Target: Face-up LIGHT Attribute monsters
function s.atktg(e,c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end

--Value: Reduce ATK based on total number of LIGHT Attribute monsters in both Graveyards
function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(s.grave_filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
    return -g:GetCount()*100
end

--Filter: LIGHT Attribute monsters in the Graveyard
function s.grave_filter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT)
end

