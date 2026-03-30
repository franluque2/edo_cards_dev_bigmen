--Protoss Probe
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Link summon method
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)

    --You can only Special Summon "Protoss Probe"(s) once per turn.
    c:SetSPSummonOnce(id)


    --Once per turn: You can place 1 "Protoss" Link Spell from your Deck or GY face-up in your Spell/Trap Zone so it is co-linked, also you cannot Special Summon for the rest of this turn, except Machine, Psychic or Cyberse monsters.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCountLimit(1)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.placetarg)
    e1:SetOperation(s.placeoper)
    c:RegisterEffect(e1)
    
end
s.listed_series={SET_PROTOSS}

function s.matfilter(c,lc,stype,tp)
	return c:IsSetCard(SET_PROTOSS,lc,stype,tp) and not c:IsType(TYPE_LINK,lc,stype,tp)
end



function s.placetgfilter(c,e,tp)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(SET_PROTOSS)
        and c:IsType(TYPE_LINK)
        and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end

function s.placetarg(e,tp,eg,ep,ev,re,r,rp,chk)
    local zones=(Duel.GetMatchingGroup(s.fulinkfilter,tp,LOCATION_ONFIELD,0,nil):GetLinkedZone(tp)>>8) & 0xff

    if chk==0 then return (zones>0) and Duel.IsExistingMatchingCard(s.placetgfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
end

function s.fulinkfilter(c)
    return c:IsType(TYPE_LINK) and c:IsFaceup() and (c:IsLocation(LOCATION_SZONE) or c:GetSequence()<5)
end

function s.placeoper(e,tp,eg,ep,ev,re,r,rp)
    local zones=(Duel.GetMatchingGroup(s.fulinkfilter,tp,LOCATION_ONFIELD,0,nil):GetLinkedZone(tp)>>8) & 0xff
    if zones==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.placetgfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        local zonetoplace=(Duel.GetMatchingGroup(s.fulinkfilter,tp,LOCATION_ONFIELD,0,nil):GetLinkedZone(tp)>>8) & 0xff
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true,zonetoplace)
    end

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