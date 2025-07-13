--Old Earthbound Prisoner Wallina
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --If a face-up card is in the Field Zone: You can Special Summon this card (from your Hand). 
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- If this card is Normal or Special Summoned: You can add 1 level 5 or lower "Earthbound" monster from your Deck to your Hand, also you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except Fusion or Synchro monsters.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- If this card is sent from the field to the GY as Synchro material, or to activate the effect of "Harmonic Synchro Fusion": You can add 1 "Earthbound Immortal" card from your Deck to your Hand, also during your Main Phase this turn, you can Normal Summon 1 "Earthbound Immortal" monster, in addition to your Normal Summon/Set. (You can only gain this effect once per turn).
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,2})
    e4:SetCondition(s.adcon1)
    e4:SetTarget(s.adtg)
    e4:SetOperation(s.adop)
    c:RegisterEffect(e4)

    local e5=e4:Clone()
    e5:SetCode(EVENT_BE_MATERIAL)
    e5:SetCondition(s.adcon2)
    c:RegisterEffect(e5)
end
s.listed_series={SET_EARTHBOUND,SET_EARTHBOUND_IMMORTAL}
s.listed_names={7473735} -- Harmonic Synchro Fusion

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then 
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end


function s.thfilter(c)
    return c:IsSetCard(SET_EARTHBOUND) and c:IsLevelBelow(5) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        --Cannot Special Summon from the Extra Deck except Fusion or Synchro monsters this turn
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetReset(RESET_PHASE|PHASE_END)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        Duel.RegisterEffect(e1,tp)
	    aux.addTempLizardCheck(e:GetHandler(),tp,function(_,c) return not c:IsOriginalType(TYPE_FUSION|TYPE_SYNCHRO) end)
    end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO))
end

function s.adcon1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE)==7473735)
end

function s.adcon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD) and r==REASON_SYNCHRO
end

function s.adfilter(c)
    return c:IsSetCard(SET_EARTHBOUND_IMMORTAL) and c:IsAbleToHand()
end

function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.adfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        --Additional Normal Summon of an "Earthbound Immortal" monster this turn
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id,4))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_EARTHBOUND_IMMORTAL))
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end