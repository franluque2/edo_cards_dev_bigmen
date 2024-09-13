--Spiderite Drop-Off
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}

function s.spsummonfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_SPIDERITE) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP)
end

function s.noninsectdesfilter(c)
	return c:IsDestructable() and not ( c:IsFaceup() and c:IsRace(RACE_INSECT))
end

function s.revealfilter(c,e,tp)
	return (not c:IsPublic()) and
	(
	(c:IsOriginalCode(851632030) and Duel.IsExistingMatchingCard(s.spsummonfilter, tp, LOCATION_HAND, 0, 1, nil,e, tp)) or
	(c:IsOriginalCode(851632029) and Duel.IsExistingMatchingCard(s.noninsectdesfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)) or
	(c:IsOriginalCode(851632031) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_GRAVE+LOCATION_REMOVED, LOCATION_GRAVE+LOCATION_REMOVED, 1, nil))
	)
end


function s.filter(c)
	return c:IsRace(RACE_INSECT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.filter,1,false,nil,nil) and Duel.IsExistingMatchingCard(s.revealfilter, tp, LOCATION_EXTRA, 0, 1, nil,e,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.filter,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
	local tc=Duel.SelectMatchingCard(tp, s.revealfilter, tp, LOCATION_EXTRA, 0, 1,1,false,nil,e,tp)
	Duel.ConfirmCards(1-tp, tc)
	e:SetLabelObject(tc:GetFirst())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then return Duel.IsExistingMatchingCard(s.revealfilter, tp, LOCATION_EXTRA, 0, 1, nil,e,tp) end
	local tc=e:GetLabelObject()
	--Spindel
	if tc:IsOriginalCode(851632029) then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_CONJURE+CATEGORY_TODECK)
		e:SetOperation(s.desop)
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,PLAYER_ALL,LOCATION_ONFIELD)
	
	--Arachne
	elseif tc:IsOriginalCode(851632030) then

		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
		e:SetOperation(s.spop)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_HAND)

	--Payak	
	elseif tc:IsOriginalCode(851632031) then
		e:SetCategory(CATEGORY_TODECK)
		e:SetOperation(s.tdop)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end


function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.noninsectdesfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:Select(tp, 1,1,nil)
	if tc and Duel.Destroy(tc, REASON_EFFECT)>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
		Duel.BreakEffect()
		local Spiderite=WbAux.GetSpideriteling(tp)
		Duel.SendtoDeck(Spiderite, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
	end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spsummonfilter,tp,LOCATION_HAND,0,nil,e,tp)
	local tc=g:Select(tp, 1,1,nil)
	if tc and Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP) and Duel.CheckReleaseGroup(tp, Card.IsReleasableByEffect, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		Duel.BreakEffect()
		local relg=Duel.SelectReleaseGroupCost(tp,Card.IsReleasableByEffect,1,1,false,nil,nil)
		if Duel.Release(relg,REASON_EFFECT)>0 then
			local Spiderite=WbAux.GetSpideriteling(tp)
			Duel.SpecialSummon(Spiderite, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
		end
	
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbletoDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	local tc=g:Select(tp, 1,1,nil)
	if tc and Duel.SendtoDeck(tc, tc:GetFirst():GetControler(), SEQ_DECKSHUFFLE, REASON_EFFECT)>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
		Duel.BreakEffect()
		local Spiderite=WbAux.GetSpideriteling(tp)
		if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
			Duel.SendtoGrave(Spiderite, REASON_EFFECT)
		else
			Duel.Remove(Spiderite, POS_FACEUP, REASON_EFFECT)
		end
	end
end