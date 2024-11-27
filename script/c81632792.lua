--Custom Spell Card
local s,id=GetID()
function s.initial_effect(c)
    --Excavate and add WIND Zombie to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Target: Check if the deck has at least 4 cards
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
end

--Operation: Excavate, add to hand, and reorder
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Ensure deck has at least 4 cards
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end

    -- Excavate the top 4 cards
    Duel.ConfirmDecktop(tp,4)
    local g=Duel.GetDecktopGroup(tp,4)
    if #g==0 then return end

    -- Filter for WIND Attribute Zombie Type monsters
    local sg=g:Filter(s.filter,nil)

    -- Optionally add 1 WIND Zombie to the hand
    local added = false
    if #sg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local tc=sg:Select(tp,1,1,nil):GetFirst()
        if tc then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
            g:RemoveCard(tc)
            added = tc:IsCode(81632787) -- Replace with the ID for "Sky Fossil Anomalocaris"
        end
    end

    -- Place remaining cards on the bottom of the deck in any order
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
    Duel.SortDeckbottom(tp,tp,#g)

    -- Draw 1 card if "Sky Fossil Anomalocaris" was added
    if added then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end

--Filter: WIND Attribute Zombie Type monsters
function s.filter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
