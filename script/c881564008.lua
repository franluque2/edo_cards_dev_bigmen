--Fated Noble Knight - Saber
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)

    --During your Main Phase: you can shuffle any number of cards from your hand into the deck, and if you do, add up to that many Equip Spells from your Deck to your hand, also you cannot target monsters on the field or in the GYs for the rest of this turn with card effects, except "Fated" monsters. You can only use this effect of "Fated Noble Knight - Saber" once per turn.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_FATED}

function s.splimit(e,se,sp,st)
    return se:GetHandler():IsSetCard(SET_FATED)
end

function s.thfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=g:Select(tp, 1, #g, nil)
    local ct=Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    if ct==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,ct,nil)
    if #tg>0 then
        Duel.SendtoHand(tg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tg)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
        e1:SetTargetRange(LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE)
        e1:SetTarget(function(_,_c) return _c:IsMonster() and (_c:IsFacedown() or not _c:IsSetCard(SET_FATED)) end)
        e1:SetValue(s.immval)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1))

    end
end
function s.immval(e,re,rp)
	return re and re:GetHandlerPlayer()==e:GetHandlerPlayer()
end
