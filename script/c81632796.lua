--Golondrinas Roar (CT)
--Custom Rush Duel Trap Card
local s,id=GetID()
function s.initial_effect(c)
    --Activate: When an opponent's monster declares an attack
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_NEGATE)
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

--Target: Return 1 WIND Attribute Zombie Type monster from your field to your hand
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,1,0,0)
end

--Filter: WIND Attribute Zombie Type monster
function s.filter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end

--Operation: Return monster to hand, negate attack, and restrict LIGHT monsters
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local atk=Duel.GetAttacker()

    --Return the selected WIND Zombie monster to the hand
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
        --Negate the attack
        if Duel.NegateAttack() then
            --Prevent LIGHT Attribute monsters from attacking this turn
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetTargetRange(LOCATION_MZONE,0)
            e1:SetTarget(s.lightfilter)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    end
end

--Filter: LIGHT Attribute monsters
function s.lightfilter(e,c)
    return c:IsAttribute(ATTRIBUTE_LIGHT)
end

