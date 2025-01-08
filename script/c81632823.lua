--Corny Summon (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Level 4 or lower monster from the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.filter(c)
	return c:IsReleasableByEffect() and c:IsCode(74983882)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsCode(08170654,61245403,81632822,73776643,74983881,51735257) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct=Duel.Release(rg,REASON_EFFECT)
    local tc=g:GetFirst()
	if ct==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_SET_BASE_ATTACK)
        e3:SetValue(tc:GetBaseAttack()+ct*500)
        e3:SetReset(RESET_EVENT|RESETS_STANDARD)
        tc:RegisterEffect(e3)
        local e4=e3:Clone()
        e4:SetCode(EFFECT_SET_BASE_DEFENSE)
        e4:SetValue(tc:GetBaseDefense()+ct*500)
        tc:RegisterEffect(e4)
	end
    Duel.SpecialSummonComplete()
end

