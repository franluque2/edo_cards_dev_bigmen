--Igknighted Monarch
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_FIRE),1,99) 


    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e1:SetCost(s.thcost)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

end

s.listed_series={0xc8}

function s.todeckfilter(c)
    return c:IsSetCard(0xc8) and c:IsMonster() and c:IsAbleToDeckAsCost()
end




function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.todeckfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, s.todeckfilter, tp, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, 2, nil)
    Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end

    local g1=Duel.GetMatchingGroup(s.tohandfilter, tp, LOCATION_ONFIELD, 0, e:GetHandler(),e)
    local g2=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget, tp, 0, LOCATION_ONFIELD, nil,e)

    local b1=true
    local b2=((#g1>0) and (#g2>0))
    local ac=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})

    if ac==1 then
        Duel.SetOperationInfo(0, CATEGORY_CONJURE, nil, 1, tp, 0)

        e:SetLabel(0)
    elseif ac==2 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
        local tohand=g1:Select(tp, 1,1,nil)

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
        local todeck=g2:Select(tp, 1,1,nil)
        Duel.HintSelection(tohand)
        Duel.HintSelection(todeck)

        Duel.SetOperationInfo(0, CATEGORY_TOHAND, tohand, #tohand, tp, LOCATION_ONFIELD)
        Duel.SetOperationInfo(0, CATEGORY_TODECK, todeck, #todeck, 1-tp, LOCATION_ONFIELD)

        e:SetLabel(1)
    end

end

function s.tohandfilter(c,e)
    return c:IsFaceup() and c:IsSetCard(0xc8) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)

    local ac=e:GetLabel()
    if ac==0 then
        local igknight=WbAux.GetNormalIgknight(tp)
        Duel.SendtoHand(igknight, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, igknight)
	end
	if ac==1 then
        
        local ex,tohand=Duel.GetOperationInfo(0, CATEGORY_TOHAND)

        if not (tohand and s.tohandfilter(tohand:GetFirst(), e)) then return end
        local ex1,todeck=Duel.GetOperationInfo(0, CATEGORY_TODECK)
        if not (todeck and Card.IsCanBeEffectTarget(todeck:GetFirst(), e)) then return end

        if Duel.SendtoHand(tohand, tp, REASON_EFFECT)>0 then
            Duel.SendtoDeck(todeck, 1-tp, SEQ_DECKBOTTOM, REASON_EFFECT)
        end
	end

    end