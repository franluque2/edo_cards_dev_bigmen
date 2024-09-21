--Igknighted Monarch
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_FIRE),1,99) 


    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONJURE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e1:SetCost(s.thcost)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

end

s.listed_series={0xc8}

function s.todeckfilter(c)
    return c:IsSetCard(0xc8) and c:IsMonster() and c:IsAbleToDeckAsCost()
end


function s.counterfilter(c)
	return c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR)
end

function s.splimit(e,c)
	return not s.counterfilter(c)
end



function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.todeckfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, s.todeckfilter, tp, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, 2, nil)
    if Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_COST)==2 then
        e:SetLabel(1)
    end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0 end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetReset(RESET_PHASE+PHASE_END)
    e2:SetTargetRange(1,0)
    Duel.RegisterEffect(e2,tp)
end

function s.tohandfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xc8) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local b1=true
    local g1=Duel.GetMatchingGroup(s.tohandfilter, tp, LOCATION_ONFIELD, 0, e:GetHandler())
    local g2=Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)

    local b2=(#g1>0) and (#g2>0)
    local b3=(e:GetLabel()==1) and b2

    local ac=0
    if not b3 then
		ac=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b3 then
		ac=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	end

    if ac==0 or ac==2 then
        local igknight=WbAux.GetNormalIgknight(tp)
        Duel.SendtoHand(igknight, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, igknight)
	end
	if ac==1 or ac==2 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
        local tohand=g1:Select(tp, 1,1,nil)
        Duel.HintSelection(tohand)

        if Duel.SendtoHand(tohand, tp, REASON_EFFECT)>0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
            local todeck=g2:Select(tp, 1,1,nil)
            Duel.HintSelection(todeck)
            Duel.SendtoDeck(todeck, 1-tp, SEQ_DECKBOTTOM, REASON_EFFECT)
        end
	end

    end