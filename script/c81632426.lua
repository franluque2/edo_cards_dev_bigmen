--Parallel Evolution (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_EFFECT) or (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp)))
        and c:IsLevelAbove(9)
end
function s.levelsummonfilter(c,e,tp)
    return c:IsLevelBelow(8) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP_ATTACK)
end

function s.shufflefilter(c)
    return c:IsMonster() and c:IsAbleToDeckAsCost()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.levelsummonfilter, tp, LOCATION_GRAVE, 0, nil,e,tp)
	return eg:IsExists(s.filter,1,nil,tp) and #g>1 and Duel.IsExistingMatchingCard(s.shufflefilter, tp, LOCATION_GRAVE, 0, 4, nil)
end

function s.otherracefilter(c,e,tp,race)
    return s.levelsummonfilter(c,e,tp) and not c:IsRace(race)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local todeck=Duel.SelectMatchingCard(tp, s.shufflefilter, tp, LOCATION_GRAVE, 0, 2,2,false,nil)
    Duel.SendtoDeck(todeck, tp, SEQ_DECKSHUFFLE, REASON_COST)

    local g=Duel.GetMatchingGroup(s.levelsummonfilter, tp, LOCATION_GRAVE, 0, nil,e,tp)
    if #g<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc1=g:Select(tp, 1,1,false,nil)
	Duel.SpecialSummonStep(tc1:GetFirst(),0,tp,tp,false,false,POS_FACEUP_ATTACK)
    g=g:Filter(s.otherracefilter,nil,e,tp,tc1:GetFirst():GetRace())
    local tc2=g:Select(tp, 1,1,false,nil)
    Duel.SpecialSummonStep(tc2:GetFirst(),0,tp,tp,false,false,POS_FACEUP_ATTACK)
    Duel.SpecialSummonComplete()
end