--Sky Fossil Stanleycaris (CT)
local s,id=GetID()
function s.initial_effect(c)
    --Effect: Mill 3 cards from both players' decks and retrieve a specific card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Cost: Each player sends the top 3 cards of their Deck to the Graveyard
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=3
    end
    Duel.DiscardDeck(tp,3,REASON_COST)
    Duel.DiscardDeck(1-tp,3,REASON_COST)
end

--Operation: Add one of the specified cards to your hand
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--Filter: Specific cards ("Golondrinas Jail", "Golondrinas Ray", "Golondrinas Roar")
function s.filter(c)
    return c:IsCode(81632793,81632794,81632796) and c:IsAbleToHand() -- Replace these IDs with the actual IDs for the specified cards
end


