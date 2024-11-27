--Rainbow Rod (CT)
--Custom Rush Duel Trap Card
local s,id=GetID()
function s.initial_effect(c)
    --Activate: When your opponent Normal or Special Summons a monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

--Condition: When your opponent Normal or Special Summons a monster
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,1-tp)
end

--Target: Return 1 WIND Attribute Zombie Type monster you control to the hand
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

--Filter: WIND Attribute Zombie Type monster
function s.filter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end

--Operation: Return the selected monster and apply ATK boost
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
        --Apply ATK boost to all non-LIGHT monsters
        local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
        if #g>0 then
            local sc=g:GetFirst()
            while sc do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(500)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                sc:RegisterEffect(e1)
                sc=g:GetNext()
            end
        end
    end
end

--Filter: Non-LIGHT Attribute monsters
function s.atkfilter(c)
    return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_LIGHT)
end

