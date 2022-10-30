--Boss Drone Dekaizo (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

end


function s.condition(e,tp,eg,ep,ev,re,r,rp)
return (e:GetHandler():IsStatus(STATUS_SUMMON_TURN) or e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)) and
	Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter), tp, LOCATION_GRAVE, 0, 2, nil, e,tp)
end

function s.spfilter(c,e,tp)
return c:IsCode(160001033) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
if not Duel.DiscardDeck(tp,3,REASON_COST)==3 then return end
if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then return end
local g=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 2, 2,false,nil,e,tp)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
