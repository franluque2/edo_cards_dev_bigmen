--Doodlebook - Oopsies!
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

    --Draw

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cost)
	e2:SetTarget(s.drtg1)
	e2:SetOperation(s.drop1)
	c:RegisterEffect(e2)


    --Fusion Summon
    local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_DOODLE_BEAST),matfilter=s.matfilter,extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,extratg=s.extratg}

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(Fusion.SummonEffTG(params))
	e3:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e3)
	
end
s.listed_series={SET_DOODLE_BEAST}
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.drtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end


function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc:IsSetCard(SET_DOODLE_BEAST) and tc:IsMonster() then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
            Duel.Summon(tp, tc, true, nil)
        end
	end

end


function s.matfilter(c)
	return c:IsAbleToDeck()
end
function s.extrafil(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.extrafil,tp,LOCATION_REMOVED,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_REMOVED)
end
