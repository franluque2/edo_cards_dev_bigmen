--Devilcaris Trident (CT)
--Custom Rush Duel Trap Card
local s,id=GetID()
function s.initial_effect(c)
    --Activate: When an opponent's monster declares an attack
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Condition: When an opponent's monster declares an attack
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker():IsControler(1-tp)
end

--Target: Select 1 WIND Attribute Zombie Type monster you control
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end

--Filter: WIND Attribute Zombie Type monster
function s.filter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_ZOMBIE)
end

--Operation: Increase ATK based on the number of LIGHT Attribute monsters in your opponent's Graveyard
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end

    --Count LIGHT Attribute monsters in the opponent's Graveyard
    local g=Duel.GetMatchingGroup(s.grave_filter,tp,0,LOCATION_GRAVE,nil)
    local atk=g:GetCount()*100

    --Apply ATK increase
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(atk)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
end

--Filter: LIGHT Attribute monsters in the opponent's Graveyard
function s.grave_filter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT)
end

