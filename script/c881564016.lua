--Ilya the Fated Master
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    -- If this card is Normal or Special Summoned: You can Special Summon 1 "The Fated War Rock Berserker" from your Hand or Deck. You can only use this effect of "Illya the Fated Master" once per turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    --Spirit monsters you control do not have to have their effects that activate during the End Phase to return to the hand activated. 
    	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	c:RegisterEffect(e3)

    --While you control another Warrior or Spellcaster monster, your opponent cannot target this card for attacks, also they cannot target it with card effects.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_WARRIOR|RACE_SPELLCASTER),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler()) end)
    e4:SetValue(aux.imval1)
    c:RegisterEffect(e4)

    local e5=e4:Clone()
    e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e5:SetValue(aux.tgoval)
    c:RegisterEffect(e5)

    --Transforms if 3 or more "Fated" Spirit Monsters have been destroyed this duel!
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_ADJUST)
    e6:SetCountLimit(1)
    e6:SetRange(LOCATION_ALL)
    e6:SetCondition(s.transformthiscon)
    e6:SetOperation(s.transformthisop)
    c:RegisterEffect(e6)

    WbAux.StartDeadServantFilter()
end
s.listed_names={881564017} --The Fated War Rock Berserker

function s.spfilter(c,e,tp)
    return c:IsCode(881564017) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.destroyedfatedspiritfilter(c)
    return c:IsType(TYPE_SPIRIT) and c:IsSetCard(SET_FATED)
end

function s.transformthiscon(e,tp,eg,ep,ev,re,r,rp)
    return WbAux.GetDeadServantCount()>=3
end

function s.transformthisop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Card.Recreate(c, 881564058, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
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