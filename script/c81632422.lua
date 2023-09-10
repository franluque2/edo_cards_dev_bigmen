--Trion Barrier (CT)
local s,id=GetID()
function s.initial_effect(c)
	--copy spell
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={34796454}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.filter(c,e,tp)
	return c:IsCode(34796454) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.revfilter(c)
	return c:IsCode(34796454) and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAttackPos() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(Card.IsAttackPos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
	local g=Duel.SelectTarget(tp,Card.IsAttackPos,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local rev=Duel.SelectMatchingCard(tp, s.revfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
    Duel.ConfirmCards(1-tp, rev)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsAttackPos() then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp)
		if #g>=1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local num=3
            if num>Duel.GetLocationCount(tp, LOCATION_MZONE) then num=Duel.GetLocationCount(tp, LOCATION_MZONE) end
            if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then num=1 end
			local sg=g:Select(tp,1,num,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
