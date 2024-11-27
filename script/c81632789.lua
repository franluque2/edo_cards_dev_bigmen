--Sky Fossil Lyrarapax (CT)
local s,id=GetID()
function s.initial_effect(c)
    --Activate effect (Requirement: Opponent has a LIGHT monster)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Condition: Opponent must control a LIGHT Attribute monster
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_LIGHT),tp,0,LOCATION_MZONE,1,nil)
end

--Target: Ensure at least 3 cards exist in both players' decks
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 
        and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=3 end
    Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,3)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

--Operation: Each player sends 3 cards from their Deck to the Graveyard
--Then, optionally add a WIND Zombie from your Graveyard to your hand
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Mill 3 cards from each player's Deck
    Duel.DiscardDeck(tp,3,REASON_EFFECT)
    Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
    
    --Optional: Add a WIND Zombie from Graveyard to hand
    if Duel.IsExistingMatchingCard(s.wind_zombie_filter,tp,LOCATION_GRAVE,0,1,nil) 
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.wind_zombie_filter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

--Filter: WIND Attribute Zombie-Type monster
function s.wind_zombie_filter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
