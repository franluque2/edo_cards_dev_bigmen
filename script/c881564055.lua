--Yet, those hands will never hold anything

Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        local e1=Effect.CreateEffect(c)
        e1:SetCategory(CATEGORY_CONJURE)
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
    return Duel.GetCustomActivityCount(id-5,tp,ACTIVITY_CHAIN)<(1+WbAux.GetFatedChantUses(tp)) and e:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_CONJURE,nil,1,tp,0)
    Duel.SetTargetPlayer(1-tp)
end

function s.filterfunc(c)
    return not WbAux.IsIgnoreStaple(c)
end

function s.sumfilter(c)
	return c:IsSummonable(true,nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)

    --Declare the name of 1 card, if it is in either player's Main Deck add a copy of it to your hand
    local code=Duel.AnnounceCard(tp)
    local g1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,LOCATION_DECK,nil,code)
    if #g1>0 then
        local token=Duel.CreateToken(tp, code)
        Duel.SendtoHand(token, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, token)
    end

    WbAux.IncreaseFatedChantStatus(c,tp)
    local c=e:GetHandler()
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