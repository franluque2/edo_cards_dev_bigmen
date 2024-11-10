--Diktat of Eradication
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

end
s.listed_series={SET_TECHMINATOR, SET_DIKTAT}

function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_MACHINE)
end

function s.tgfilter(c,e)
	return c:IsCanBeEffectTarget(e) and (c:IsAbleToRemove() or c:IsAbleToDeck())
end

function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsAbleToRemove,nil)==#sg or sg:FilterCount(Card.IsAbleToDeck,nil)==#sg
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,0) and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,sg,#sg,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,sg,#sg,tp,0)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,rg,#rg,0,0)
	end

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)

end
function s.activate(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetTargetCards(e)
	local b1=g:FilterCount(Card.IsAbleToRemove,nil)>0
	local b2=g:FilterCount(Card.IsAbleToDeck,nil)>0
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)}, --"Banish"
		{b2,aux.Stringid(id,2)}) --"Shuffle"
	if op==1 then
		Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
	else
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	
    WbAux.CreateDiktatSummonEffect(e,tp,eg,ep,ev,re,r,rp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalRace(RACE_MACHINE)
end