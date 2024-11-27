--Sky Fossil Peytoia (CT)
local s, id = GetID()
function s.initial_effect(c)
    -- Requirement: Change battle position during the turn it is Normal Summoned
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_SINGLE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.bp_condition)
    e1:SetOperation(s.bp_operation)
    c:RegisterEffect(e1)

    -- Effect: Protect Spell/Trap and recover specific cards
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetCondition(s.st_protection_condition)
    e2:SetOperation(s.st_protection_operation)
    e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_OPPO_TURN)
    c:RegisterEffect(e2)

    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.add_condition)
    e3:SetTarget(s.add_target)
    e3:SetOperation(s.add_operation)
    e3:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_OPPO_TURN)
    c:RegisterEffect(e3)
end

-- Requirement: Change battle position
function s.bp_condition(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end

function s.bp_operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsPosition(POS_ATTACK) then
        Duel.ChangePosition(c, POS_FACEUP_DEFENSE)
    elseif c:IsPosition(POS_DEFENSE) then
        Duel.ChangePosition(c, POS_FACEUP_ATTACK)
    end
end

-- Effect 1: Spell/Trap protection
function s.st_protection_condition(e, tp, eg, ep, ev, re, r, rp)
    return re:IsActiveType(TYPE_SPELL + TYPE_TRAP) and re:GetHandler():IsControler(1 - tp)
end

function s.st_protection_operation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_SZONE, 0, nil)
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_OPPO_TURN)
        tc:RegisterEffect(e1)
    end
end

-- Effect 2: Add card from Graveyard to Hand
function s.add_condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_GRAVE, 0, 1, nil)
end

function s.filter(c)
    return c:IsCode(12345678, 23456789, 34567890) -- Replace these with the actual card IDs of "Devilcaris Trident", "Golondrinas Roar", and "Rainbow Rod"
end

function s.add_target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.add_operation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
