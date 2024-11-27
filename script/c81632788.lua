--Sky Fossil Peytoia (CT)
local s,id=GetID()
function s.initial_effect(c)
    --Single Ignition Effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Condition: During the turn this card was Normal Summoned
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end

--Operation: Change battle position, protect Spell/Trap cards, and retrieve a specific card
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    --Change this card's battle position
    if c:IsPosition(POS_FACEUP_ATTACK) then
        Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
    elseif c:IsPosition(POS_FACEUP_DEFENSE) then
        Duel.ChangePosition(c,POS_FACEUP_ATTACK)
    end

    --Apply protection to Spell/Trap cards until the end of the opponent's next turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(aux.TRUE)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
    Duel.RegisterEffect(e1,tp)

    --Optional: Add a specific card from the Graveyard to the hand
    if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

--Filter: Specific card names
function s.filter(c)
    return c:IsCode(81632795, 81632796, 81632797) and c:IsAbleToHand() -- Use actual IDs for "Devilcaris Trident," "Golondrinas Roar," and "Rainbow Rod"
end

