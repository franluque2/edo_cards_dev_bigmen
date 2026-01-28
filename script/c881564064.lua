--Sakura the Fated Master
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --If this card is Normal Summoned: You can add 1 non-Spirit "Fated" monster from your Deck to your hand. 
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.thtarget)
    e1:SetOperation(s.thoperation)
    c:RegisterEffect(e1)

    -- When this card is targetted for a card effect (Quick Effect): you can banish this card until the End Phase, and if you do, Special Summon 1 "Shirou the Fated Master" or "The Fated Reptilianne Rider" from your Hand or Deck. 
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_BECOME_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        return eg:IsContains(e:GetHandler())
    end)
    e2:SetTarget(s.sptarg)
    e2:SetOperation(s.spoper)
    c:RegisterEffect(e2)

    WbAux.StartDeadServantFilter()

    --Transforms if 3 or more "Fated" Spirit Monsters have been destroyed this duel!
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_ADJUST)
    e6:SetCountLimit(1)
    e6:SetRange(LOCATION_ALL)
    e6:SetCondition(s.transformthiscon)
    e6:SetOperation(s.transformthisop)
    c:RegisterEffect(e6)
end
s.listed_series={SET_FATED}
s.listed_names={881564003, 881564061} -- Shirou the Fated Master, The Fated Reptillianne Rider

function s.adfilter(c)
    return c:IsSetCard(SET_FATED) and c:IsMonster() and not c:IsType(TYPE_SPIRIT) and c:IsAbleToHand()
end

function s.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thoperation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.adfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.spfilter(c,e,tp)
    return (c:IsCode(881564003) or c:IsCode(881564061)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemove()
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>=0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spoper(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if aux.RemoveUntil(c,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end


function s.transformthiscon(e,tp,eg,ep,ev,re,r,rp)
    return WbAux.GetDeadServantCount()>=3
end

function s.transformthisop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Card.Recreate(c, 881564085, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
    if c:IsLocation(LOCATION_HAND) then
        Duel.ShuffleHand(tp)
    elseif c:IsLocation(LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
    elseif c:IsLocation(LOCATION_REMOVED) then
        local pos=c:GetPosition()
        Duel.SendtoGrave(c, REASON_RULE)
        Duel.Remove(c, pos, REASON_RULE)
    elseif c:IsLocation(LOCATION_GRAVE) then
        Duel.Remove(c, POS_FACEUP, REASON_RULE)
        Duel.SendtoGrave(c, REASON_RULE)
    end
end