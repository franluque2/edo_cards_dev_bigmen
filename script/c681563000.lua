--Vision Mirage
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
local CARD_GRAND_JUPITER=16255173
s.listed_series={SET_VISION_HERO}
s.listed_names={CARD_GRAND_JUPITER} -- "The Grand Jupiter"

function s.sendfilter(c)
    return c:IsSetCard(SET_VISION_HERO) and c:IsMonsterCard() and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,tp,800)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsSetCard(SET_VISION_HERO) and c:IsMonster() and not c:IsForbidden()
end
function s.spfilter(c,e,tp)
	return (c:IsSetCard(SET_VISION_HERO) or c:IsCode(CARD_GRAND_JUPITER)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0
	local both=b1 and e:GetLabel()==1
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{true,aux.Stringid(id,2)},
		{both,aux.Stringid(id,4)})
	local breakeffect=false
	if op==1 or op==3 then
		--Place 1 "Vision Hero" monster on the field as a continuous trap
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
        if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
            e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
            tc:RegisterEffect(e1)
            breakeffect=true
        end
	end
	if op==2 or op==3 then
		if breakeffect then Duel.BreakEffect() end
		--Take 800 damage, then you can Special Summon 1 "Vision HERO" or The Grand Jupiter from your hand or GY, but it cannot attack directly
		if Duel.Damage(tp,800,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
			Duel.BreakEffect()
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
				--It cannot attack directly
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(3207)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				sc:RegisterEffect(e1)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
