--Sealed Gate (CT)
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={0x155d}
function s.cfilter(c)
	return c:IsSetCard(0x155d) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.sumfilter(c,e,tp)
    return c:IsSetCard(0x155d) and c:IsMonster() and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, true, false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local bg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return bg:GetClassCount(Card.GetCode)>2 and ft>0
		and Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil,e,tp) end
    local g=aux.SelectUnselectGroup(bg,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_REMOVE)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(#g)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_DECK+LOCATION_HAND, 0, 1, 1, false,nil,e,tp)
    if tc then
        Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, true, false, POS_FACEUP)
    end
end
