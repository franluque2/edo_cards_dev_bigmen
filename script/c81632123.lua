--Substitute Pain (CT)
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={511004336}

function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x1107)>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.filter(c)
	return c:GetCounter(0x1107)>=1
end

function s.tgfilter(c)
	return (Card.ListsCode(c,511004336) or c:IsCode(511004337) or c:IsCode(511004339) or c:IsCode(511004327) or c:IsCode(511004336) or c:IsCode(511004328)) and c:IsAbleToHand()
end

function s.ssfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dest=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local dam=Duel.GetCounter(tp,LOCATION_ONFIELD,LOCATION_ONFIELD,0x1107)*400
	local tdam=Duel.Damage(p,dam,REASON_EFFECT)

	if tdam then
		Duel.BreakEffect()
		Duel.Destroy(dest, REASON_EFFECT)
		if tdam>=1000 and Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil) then
			Duel.BreakEffect()
			Duel.Hint(HINT_MESSAGE, tp, HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp, s.tgfilter, tp,LOCATION_DECK, 0, 1, 1,false,nil)
			Duel.SendtoHand(g, tp, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, g)
		end

		if tdam>=2000 and dest then
			Duel.BreakEffect()
			Duel.Hint(HINT_MESSAGE, tp, HINTMSG_SPSUMMON)
			local g=Group.Select(dest, tp, 1, 1,nil)
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end

end
