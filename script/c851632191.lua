--Chaos Armed Dragon
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK),1,99)

    	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)

    	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e2:SetCost(s.thcost)
    e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)


    	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
    e3:SetCost(s.thcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)


    	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.ctfilter)

end
s.listed_series={SET_CHAOS,SET_BLACK_LUSTER_SOLDIER}
function s.synfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
end
function s.ctfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or s.synfilter(c)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	--Cannot Special Summon monsters from the Extra Deck, except LIGHT or DARK Synchro monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not s.synfilter(c) end)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_SYNCHRO) or not c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
end


function s.thfilter(c)
	return (((c:IsSetCard(SET_CHAOS) or c:IsSetCard(SET_BLACK_LUSTER_SOLDIER)) and c:IsMonster() and c:IsLevelAbove(7) and not c:IsSummonableCard()) or (c:IsSetCard(SET_CHAOS) and c:IsTrap()))  and c:IsAbleToHand()
end

function s.remfilter2(c,c1)
    return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsMonster() and c:IsAbleToRemove() and c:IsLevel(c1:GetLevel()) and not c:IsAttribute(c1:GetAttribute())
end

function s.remfilter1(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsMonster() and c:IsAbleToRemove() and c:HasLevel() and Duel.IsExistingMatchingCard(s.remfilter2,c:GetControler(),LOCATION_DECK,0,1,nil,c)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.remfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.remfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    local c1=g:GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,s.remfilter2,tp,LOCATION_DECK,0,1,1,nil,c1)
    if #g2==0 then return end
    g:Merge(g2)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id, 0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local thg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #thg>0 then
            Duel.SendtoHand(thg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,thg)
        end
    else
        Duel.ShuffleDeck(tp)
	end
end


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
function s.spfilter(c,e,tp,c1)
    return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsLevel(c1:GetLevel()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and not c:IsAttribute(c1:GetAttribute())
end
function s.filter1(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:HasLevel() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCountFromEx(tp, tp)>0
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)

end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end