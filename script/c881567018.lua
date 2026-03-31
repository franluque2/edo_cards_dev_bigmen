--Protoss Warp-In
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon 1 "Protoss" monster from your Deck  (If your opponent does not control a monster at resolution, you can only Special Summon it to your Linked Main monster Zone)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,{id,EFFECT_COUNT_CODE_OATH})
	c:RegisterEffect(e1)
    
end
s.listed_series={SET_PROTOSS}

function s.spfilter(c,e,tp, zone)
    return c:IsSetCard(SET_PROTOSS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false, zone)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local zones=Duel.GetLinkedZone(tp)
    if Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil) then zones=0xff end
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,zones) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local zones=Duel.GetLinkedZone(tp)
    if Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil) then zones=0xff end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,zones)
    local tc=g:GetFirst()
    if tc then
         Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zones)
    end
    --also you cannot Special Summon for the rest of this turn, except Machine, Psychic or Cyberse monsters.
    local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
end


function s.splimit(e,c)
    return not c:IsRace(RACE_MACHINE) and not c:IsRace(RACE_PSYCHIC) and not c:IsRace(RACE_CYBERSE)
end
