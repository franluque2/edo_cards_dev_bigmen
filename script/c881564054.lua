--Have withstood pain to create many weapons

Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        local e1=Effect.CreateEffect(c)
        e1:SetCategory(CATEGORY_CONJURE+CATEGORY_DRAW)
        e1:SetType(EFFECT_TYPE_ACTIVATE)
        e1:SetCode(EVENT_FREE_CHAIN)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCondition(s.confunc)
        e1:SetTarget(s.target)
        e1:SetOperation(s.activate)
        c:RegisterEffect(e1)


        WbAux.UpdateFatedChantStatus(c)

    	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not (re:GetHandler():IsCode(CARD_FATED_CHANT)) end)

        WbAux.RegisterStartedInDeckCards()
end
s.listed_names={CARD_FATED_CHANT,id+1}
s.listed_series={SET_FATED}

function s.confunc(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCustomActivityCount(id-4,tp,ACTIVITY_CHAIN)<(1+WbAux.GetFatedChantUses(tp)) and e:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_CONJURE,nil,1,tp,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,0)

    Duel.SetTargetPlayer(1-tp)
end

function s.filterfunc(c)
    return not WbAux.IsIgnoreStaple(c)
end

function s.sumfilter(c)
	return c:IsSummonable(true,nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)

    WbAux.IncreaseFatedChantStatus(c,tp)
    local c=e:GetHandler()

    --Look at your opponent's hand, then choose 1 card in it to add a copy of it from Outside the Duel to your hand, 
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local g=Duel.GetMatchingGroup(aux.TRUE,p,LOCATION_HAND,0,nil)
    Duel.ConfirmCards(1-p, g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tg=g:Select(1-p, 1, 1, nil)
    if tg and #tg>0 then
        local token=Duel.CreateToken(1-p, tg:GetFirst():GetOriginalCode())
        Duel.SendtoHand(token, 1-p, REASON_EFFECT)
        Duel.ConfirmCards(p, token)
    end
    Duel.ShuffleHand(1-p)
    Duel.ShuffleHand(p)
    --then you can apply the following effect Shuffle your hand into the Deck, then draw the same number of cards.
    if Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        local hand=Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
        local handcount=#hand
        if handcount>0 then
            Duel.SendtoDeck(hand, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
            Duel.ShuffleDeck(tp)
            Duel.Draw(tp, handcount, REASON_EFFECT)
        end
    end

	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		if c:IsHasEffect(EFFECT_CANNOT_TO_HAND) then return end
		c:CancelToGrave()
		Duel.SendtoHand(c, tp, REASON_EFFECT)
	end
    Duel.ShuffleHand(tp)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return c:GetFlagEffect(CARD_FATED_CHANT-1)>0 and not (c:IsSetCard(SET_FATED)) end)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)

end