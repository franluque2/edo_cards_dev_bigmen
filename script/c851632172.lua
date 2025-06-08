--Omas Geheimrezept (Grandma's Secret Recipe)
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.thcost)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_names={30243636}

function s.descfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local g=Duel.GetMatchingGroup(s.descfilter,tp,LOCATION_GRAVE|LOCATION_ONFIELD,0,1,nil)
	if aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,0)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_REMOVE)
	    if Duel.Remove(sg,POS_FACEUP,REASON_COST)>0 then
            Duel.SetTargetParam(1)
        end
	end
end


function s.spfilter(c,e,tp)
    local loc=LOCATION_MZONE
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then loc=0 end

	return c:IsRitualMonster() and c:IsCode(30243636) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,loc,1,nil,e,c)
end
function s.cfilter(c,e,sc)
	return c:IsCanBeRitualMaterial(sc) and not c:IsImmuneToEffect(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rparams={filter=aux.FilterBoolFunction(Card.IsCode,30243636),lvtype=RITPROC_EQUAL}
	local rittg=Ritual.Target(rparams)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	rittg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)

    if e:IsHasType(EFFECT_TYPE_ACTIVATE) and ct>0 then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local loc=LOCATION_MZONE
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then loc=0 end

		--Tribute 1 monster
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if not sc then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local rg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,loc,1,1,nil,e,sc)
		if #rg==0 then return end
		sc:SetMaterial(rg)
		Duel.ReleaseRitualMaterial(rg)
		Duel.BreakEffect()
		if Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)==0 then return end
		sc:CompleteProcedure()
end


function s.filter(c)
	return c:IsSetCard({SET_RECIPE,SET_FRIESLA}) and not c:IsCode(id) and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,5,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,5,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local td=tg:Filter(Card.IsRelateToEffect,nil,e)
	if not tg or #td<=0 then return end
	Duel.SendtoDeck(td,nil,SEQ_DECKTOP,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
	if ct>0 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end