--Virtual World Ritual (CT)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1657)

	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetCost(s.bancost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetCost(s.spsumcost)
	e5:SetTarget(s.spsumtg)
	e5:SetOperation(s.spsumop)
	c:RegisterEffect(e5)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,3})
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

end

s.listed_names={99267150}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	return true
end
function s.cfilter(c,e,tp)
	return c:IsMonster() and not c:IsPublic() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetRace(),c:GetCode())
end
function s.spfilter(c,e,tp,race,code)
	return c:IsRace(race) and not c:IsCode(code)
		and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local res=e:GetLabel()==-1
		e:SetLabel(0)
		return res
	end
    if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	e:SetLabel(rc:GetRace(),rc:GetCode())
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
	else
		e:SetLabel(0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)

end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then return end
	local race,code=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,race,code):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT) then
        Duel.ConfirmCards(1-tp,tc)
	end
end

function s.bancost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.setconfilter,1,nil,tp) end
	local g=eg:Filter(s.setconfilter,nil,tp)
	if #g==0 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local c=e:GetHandler()
	local g2=g:Select(tp, 1,1,nil)
	local tc=g2:GetFirst()

	Duel.Remove(g2,POS_FACEUP,REASON_COST)
	Duel.AdjustInstantly(tc)
	tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD-RESET_REMOVE,0,0)
	c:CreateRelation(tc,RESET_EVENT|RESETS_STANDARD)
	tc:CreateRelation(c,RESET_EVENT|RESETS_STANDARD)

end

function s.setconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsAbleToRemove() and not c:IsReasonPlayer(tp)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)

	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.setconfilter,1,nil,tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(0x1657)<5 end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1657, 1)
	end
end

function s.shufflebackfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end

function s.spsumfilter(c,e,tp)
	return c:IsCode(99267150) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false)
end

function s.spsumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1657,5,REASON_COST) and Duel.IsExistingMatchingCard(s.shufflebackfilter, tp, LOCATION_REMOVED, 0, 5, nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.shufflebackfilter,tp,LOCATION_REMOVED,0,5,5,nil)
	e:GetHandler():RemoveCounter(tp,0x1657,5,REASON_COST)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_COST)
end
function s.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spsumfilter, tp, LOCATION_EXTRA, 0, 1, nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,0,0)
end
function s.spsumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spsumfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		if Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)>0 then
			g:GetFirst():CompleteProcedure()
			if Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				local sg=Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local tg=sg:Select(tp,1,1,nil)
				Duel.HintSelection(tg)
				Duel.Destroy(tg,REASON_EFFECT)
			end
		end
	end
end


function s.desfilter(c,rc)
	return c:GetFlagEffect(id)~=0 and c:IsRelateToCard(rc)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.desfilter, tp, LOCATION_REMOVED, 0, nil, c)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter, tp, LOCATION_REMOVED, 0, nil, e:GetHandler())
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end