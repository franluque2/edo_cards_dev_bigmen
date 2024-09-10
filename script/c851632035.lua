--Ojusu of 108 Incantations
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_CONJURE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCode(EVENT_TO_HAND)
    e2:SetTarget(s.addtar)
    e2:SetOperation(s.adop)
    e2:SetCountLimit(1,{id,1})
	c:RegisterEffect(e2)


    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptar)
    e3:SetOperation(s.spop)
    e3:SetCountLimit(1,{id,2})
	c:RegisterEffect(e3)

end
s.listed_card_types={TYPE_SPIRIT}

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_GRAVE, 0, nil, id)>7
end

function s.spiritfilter(c,e,tp)
	return c:IsType(TYPE_SPIRIT) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spiritfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local num=Duel.GetLocationCount(tp, LOCATION_MZONE)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then num=1 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spiritfilter,tp,LOCATION_HAND,0,1,num,nil,e,tp)
	if #g>0 then
        Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, true, false, POS_FACEUP)
	end
end


function s.previouscontrolerfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end

function s.addtar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.previouscontrolerfilter, 1, nil, tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_CONJURE,nil,1,tp,0)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.CreateToken(tp, id)
    Duel.SendtoHand(tc, tp, REASON_EFFECT)
    Duel.ConfirmCards(1-tp, tc)
end

function s.filter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
