--Corsage the Rikka Queen
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),6,2)
    --You can detach 1 material from this card; Special Summon 1 "Rikka" monster from your Deck, but it cannot activate its effects. 
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(Cost.DetachFromSelf(1,1,nil))
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --If this card, or a monster you control, is Tributed: You can Set 1 "Rikka" Spell/Trap from your Deck or GY. You can only use each effect of "Corsage the Rikka Queen" once per turn.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_RELEASE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.adcon)
    e2:SetTarget(s.adtg)
    e2:SetOperation(s.adop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_RIKKA}

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_RIKKA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        local tc=g:GetFirst()

        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            --Cannot activate effects this turn
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(3302)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_TRIGGER)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
        Duel.SpecialSummonComplete()
    end
end

function s.spcfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (eg:IsExists(s.spcfilter,1,nil,tp) and c:IsLocation(LOCATION_MZONE)) or
           (c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and eg:IsContains(c))
end

function s.adfilter(c)
    return c:IsSetCard(SET_RIKKA) and c:IsSpellTrap() and c:IsSSetable()
end

function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.adfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g)
    end
end