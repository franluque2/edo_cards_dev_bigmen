--Custom Equip Spell Card
local s,id=GetID()
function s.initial_effect(c)
    --Activate and equip
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    --Equip effect: Increase ATK
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.atkvalue)
    c:RegisterEffect(e2)

    --Continuous effect: Change opponent's monsters to LIGHT Attribute
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.light_condition)
    e3:SetOperation(s.light_operation)
    c:RegisterEffect(e3)

    --Equip limit
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_EQUIP_LIMIT)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetValue(s.eqlimit)
    c:RegisterEffect(e4)
end

--Target: Select 1 monster to equip this card to
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

--Operation: Equip this card to the selected monster
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Equip(tp,e:GetHandler(),tc)
    end
end

--Equip Limit: Can only be equipped to monsters
function s.eqlimit(e,c)
    return c:IsType(TYPE_MONSTER)
end

--ATK Increase Value: Total number of LIGHT monsters in both players' Graveyards x 100
function s.atkvalue(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,ATTRIBUTE_LIGHT)
    return g:GetCount() * 100
end

--Condition: Equipped monster is a WIND Attribute Zombie Type monster
function s.light_condition(e)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and ec:IsAttribute(ATTRIBUTE_WIND) and ec:IsRace(RACE_ZOMBIE)
end

--Operation: Temporarily change all opponent's monsters (field + Graveyard) to LIGHT Attribute
function s.light_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not s.light_condition(e) then return end

    -- Change Attributes of monsters on opponent's field
    local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g1) do
        if not tc:IsAttribute(ATTRIBUTE_LIGHT) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
            e1:SetValue(ATTRIBUTE_LIGHT)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_LEAVE)
            tc:RegisterEffect(e1)
        end
    end

    -- Change Attributes of monsters in opponent's Graveyard
    local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_GRAVE,nil)
    for tc in aux.Next(g2) do
        if not tc:IsAttribute(ATTRIBUTE_LIGHT) then
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
            e2:SetValue(ATTRIBUTE_LIGHT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_LEAVE)
            tc:RegisterEffect(e2)
        end
    end
end
