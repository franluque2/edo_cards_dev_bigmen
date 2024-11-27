--Sky Fossil Aegirocassis (CT)
local s,id=GetID()
function s.initial_effect(c)
    --Requirement: Reveal 1 Level 7 WIND Zombie monster in your hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Condition: None specific, can be activated while face-up on the field
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return true
end

--Cost: Reveal 1 Level 7 WIND Zombie monster in your hand
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.reveal_filter,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.reveal_filter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
end

--Filter: Level 7 WIND Zombie monster
function s.reveal_filter(c)
    return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_ZOMBIE)
end

--Operation: This card is treated as 2 Tributes for WIND Zombie monsters
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
    e1:SetValue(s.tribute_filter)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end

--Filter: WIND Attribute Zombie Type monsters
function s.tribute_filter(e,c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_ZOMBIE)
end

