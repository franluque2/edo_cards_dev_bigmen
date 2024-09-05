--Arachne, Spiderite Broodmother
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),1,1,Synchro.NonTuner(nil),2,99)
	c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.spspidercost)
	e1:SetTarget(s.spspidertg)
	e1:SetOperation(s.spspiderop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_CONJURE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.adspidercost)
	e2:SetTarget(s.adspidertg)
	e2:SetOperation(s.adspiderop)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_CONJURE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(s.shufspidercost)
	e3:SetTarget(s.shufspidertg)
	e3:SetOperation(s.shufspiderop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}

function s.sendfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(SET_SPIDERITE)
end

function s.shufspidercost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sendfilter, tp, LOCATION_EXTRA, 0, 1, nil) and not Card.IsPublic(e:GetHandler()) end
	Duel.ConfirmCards(1-tp, e:GetHandler())
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp, s.sendfilter, tp, LOCATION_EXTRA, 0, 1,1,false,nil)
	Duel.SendtoGrave(tc, REASON_COST)
end
function s.shufspidertg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.shufspiderop(e,tp,eg,ep,ev,re,r,rp)
	for i = 1, 3, 1 do
		local Spideriteling=WbAux.GetSpideriteling(tp)
		Duel.SendtoDeck(Spideriteling, tp, SEQ_DECKTOP, REASON_EFFECT)
	end
	Duel.ShuffleDeck(tp)
	
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,3),nil)
end


function s.discardfilter(c)
	return c:IsDiscardable(REASON_COST) and c:IsSetCard(SET_SPIDERITE)
end

function s.adspidercost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.discardfilter, tp, LOCATION_HAND, 0, 1, nil) and not Card.IsPublic(e:GetHandler()) end
	Duel.ConfirmCards(1-tp, e:GetHandler())
	Duel.DiscardHand(tp, s.discardfilter, 1,1, REASON_COST, nil)
end
function s.adspidertg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.adspiderop(e,tp,eg,ep,ev,re,r,rp)
	local Spideriteling=WbAux.GetSpideriteling(tp)
	Duel.SendtoHand(Spideriteling, tp, REASON_EFFECT)
	Duel.ConfirmCards(1-tp, Spideriteling)
	Duel.ShuffleHand(tp)
	
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,3),nil)
end


function s.spspidercost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp, 500) and not Card.IsPublic(e:GetHandler()) end
	Duel.ConfirmCards(1-tp, e:GetHandler())
	Duel.PayLPCost(tp, 500)

end
function s.spspidertg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, nil)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, CARD_SPIDERITELING, SET_SPIDERITE, TYPE_NORMAL, 0, 0, 1, RACE_INSECT, ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spspiderop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, CARD_SPIDERITELING, SET_SPIDERITE, TYPE_NORMAL, 0, 0, 1, RACE_INSECT, ATTRIBUTE_LIGHT) then
		local Spideriteling=WbAux.GetSpideriteling(tp)
		Duel.SpecialSummon(Spideriteling, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
	end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,3),nil)
end

function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT)
end