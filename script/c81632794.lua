--Golondrinas Ray (CT)
local s,id=GetID()
function s.initial_effect(c)
    --Activate: Equip to a monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    --Equip limit: Only one monster can be equipped
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(s.eqlimit)
    c:RegisterEffect(e2)
end

--Equip limit: Equip only to a monster
function s.eqlimit(e,c)
    return true
end

--Target: Select a monster to equip this card
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

--Operation: Equip the card and apply effects
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()

    if not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    Duel.Equip(tp,c,tc)

    --Increase ATK based on the number of LIGHT monsters in both Graveyards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(s.atkval)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)

    --Change opponent's monsters and Graveyard monsters to LIGHT if equipped monster is WIND Zombie
    if tc:IsAttribute(ATTRIBUTE_WIND) and tc:IsRace(RACE_ZOMBIE) then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
        e2:SetValue(ATTRIBUTE_LIGHT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        Duel.RegisterEffect(e2,tp)
    end
end

--Calculate ATK boost based on LIGHT Attribute monsters in both Graveyards
function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(s.grave_filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
    return g:GetCount()*100
end

--Filter: LIGHT Attribute monsters in the Graveyard
function s.grave_filter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT)
end

