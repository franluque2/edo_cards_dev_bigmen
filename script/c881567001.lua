--Protoss Gateway
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	
    --You cannot Normal or Special Summon monsters to your Zones this card points to, except "Protoss" monsters. This effect cannot be negated.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FORCE_MZONE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetTargetRange(0xff,0)
    e2:SetTarget(s.ztarget)
	e2:SetValue(s.znval)
	c:RegisterEffect(e2)

    --During your Main Phase: You can Special Summon any number of "Protoss" Psychic monsters from your Hand or Deck to your Linked Main Monster Zones (if this card is not co-Linked at resolution, you can only Special Summon 1 max). You can only use this effect of "Protoss Gateway" once per turn. 
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)


end
s.listed_series={SET_PROTOSS}

function s.ztarget(e,c)
    return c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_MONSTER) and not c:IsSetCard(SET_PROTOSS)
end

function s.znval(e,c,fp,rp,r)
    return ~(e:GetHandler():GetLinkedZone())
end

function s.spfilter(c,e,tp,zone)
    return c:IsSetCard(SET_PROTOSS) and c:IsRace(RACE_PSYCHIC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local zones=Duel.GetFreeLinkedZone(tp)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,zones) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local zones=Duel.GetFreeLinkedZone(tp)
    if zones<=0 then return end
    local num=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zones)
    if e:GetHandler():GetMutualLinkedGroupCount()==0 then num=1 end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then num=1 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,num,nil,e,tp,zones)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zones)
    end
end