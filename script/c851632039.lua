--Flamvell Minotaur
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),1,1,Synchro.NonTuner(nil),1,99)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(_e) return Duel.GetFieldGroupCount(_e:GetHandlerPlayer(),0,LOCATION_REMOVED)*200 end)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.ddcon)
	e3:SetTarget(s.ddtg)
	e3:SetOperation(s.ddop)
	c:RegisterEffect(e3)

end
s.listed_series={SET_FLAMVELL}


function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.damfilter(c)
	return c:IsSetCard(SET_FLAMVELL)
end

function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local g=Duel.GetMatchingGroup(s.damfilter,tp,LOCATION_GRAVE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*200
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)

end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.damfilter,tp,LOCATION_GRAVE,0,nil)
	local dam=g:GetClassCount(Card.GetCode)*200
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end


function s.filter(c)
	return c:IsSetCard(SET_FLAMVELL) and c:IsAbleToHand()
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
    Duel.HintSelection(g)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local tohand=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1,1,false,nil)
            if Duel.SendtoHand(tohand, tp, REASON_EFFECT) then
                Duel.ConfirmCards(1-tp, tohand)
            end

        end
	end
end
