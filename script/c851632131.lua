--Iron Chain Spy
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)

	
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_EARTH)==#g
end

function s.rmfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c) and c:IsMonster()
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x25) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false,false)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return c~=chkc and chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,c)
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
    end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		if Duel.Remove(g, POS_FACEUP, REASON_EFFECT)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local tosum=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_EXTRA, 0, 1,1,false,nil,e,tp):GetFirst()
            if tosum then
                Duel.SpecialSummon(tosum, SUMMON_TYPE_SYNCHRO, tp,tp, false,false, POS_FACEUP)
                Card.CompleteProcedure(tosum)
            end
        end
	end
end