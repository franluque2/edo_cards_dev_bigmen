--Sky Fossil Excavation (CT)
local s,id=GetID()
function s.initial_effect(c)
    --Effect: Excavate top 4 cards, add WIND Zombie, and draw 1 if "Sky Fossil Anomalocaris" is added
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

--Target: None required
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
end

--Operation: Excavate top 4 cards and apply the effect
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end

    -- Excavate the top 4 cards
    Duel.ConfirmDecktop(tp,4)
    local g=Duel.GetDecktopGroup(tp,4)
    if #g==0 then return end

    -- Filter for WIND Attribute Zombie Type monsters
    local sg=g:Filter(s.filter,nil)

    -- Optionally add 1 WIND Zombie to the hand
    if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local tc=sg:Select(tp,1,1,nil):GetFirst()
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
        g:RemoveCard(tc)

        -- Check if "Sky Fossil Anomalocaris" was added
        if tc:IsCode(81632787) then -- Replace with the actual ID for "Sky Fossil Anomalocaris"
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end

    -- Place remaining cards on the bottom of the Deck in any order
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
    Duel.SortDeckbottom(tp,tp,#g)
end

--Filter: WIND Attribute Zombie Type monsters
function s.filter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end

