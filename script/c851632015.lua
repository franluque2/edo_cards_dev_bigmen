--Vanguard of the Sunken City
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	--This card's name become "Abyssal Dredge"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_HAND)
	e1:SetValue(CARD_ABYSSAL_DREDGE)
	c:RegisterEffect(e1)

    --special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
    e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

    --Shuffle 3 and Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_CONJURE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_ABYSSAL_DREDGE}
function s.tdfilter(c)
	return (c:IsCode(CARD_ABYSSAL_DREDGE) or c:ListsCode(CARD_ABYSSAL_DREDGE)) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,3,nil) and WbAux.CanPlayerSummonDredge(tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,tp,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 or Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
    if WbAux.CanPlayerSummonDredge(tp) then
        WbAux.SpecialSummonDredge(tp)
    end
end

function s.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_AQUA)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

--Workaround in case the script for abyssal dredge was not loaded
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp, CARD_ABYSSAL_DREDGE)==0 then
        Duel.RegisterFlagEffect(tp,CARD_ABYSSAL_DREDGE,0,0,1)
    end
end