--Sky Fossil Anomalocaris (CT)
local s, id = GetID()
function s.initial_effect(c)
    -- Requirement + Effect
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0)) -- Effect description
    e1:SetCategory(CATEGORY_DECKDES + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1) -- Once per turn
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Requirement: Opponent has a face-up monster
function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil)
end

-- Cost: Send the top card of your Deck to the Graveyard
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp, 1) end
    Duel.DiscardDeck(tp, 1, REASON_COST)
end

-- Effect: All non-LIGHT Attribute monsters gain 600 ATK
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.atkfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(600)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(e1)
    end
end

-- Filter for non-LIGHT Attribute monsters
function s.atkfilter(c)
    return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_LIGHT)
end
