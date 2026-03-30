--Protoss Stargate
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

	--During your Main Phase: You can Special Summon 1 Cyberse "Protoss" monster from your Hand or Deck to your Main Monster Zone this card points to, then if this card was co-Linked at resolution, the summoned monster gains the following effect for the rest of this turn
	--- This card's effects cannot be negated.
	--You can only use this effect of "Protoss Robotics Bay" once per turn. 
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
s.counter_place_list={0x1021} -- Guard Counter

function s.ztarget(e,c)
    return c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_MONSTER) and not c:IsSetCard(SET_PROTOSS)
end

function s.znval(e,c,fp,rp,r)
    return ~(e:GetHandler():GetLinkedZone())
end

function s.spfilter(c,e,tp,zone)
	return c:IsSetCard(SET_PROTOSS) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zones=e:GetHandler():GetFreeLinkedZone(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,zones) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zones=e:GetHandler():GetFreeLinkedZone(tp)
	if zones<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,zones)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zones) then
		if e:GetHandler():GetMutualLinkedGroupCount()>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)
		end
	end
	Duel.SpecialSummonComplete()
end