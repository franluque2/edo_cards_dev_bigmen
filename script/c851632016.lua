--Igknighted Pheonix - The True Dracoslayer
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Pendulum procedure
	Pendulum.AddProcedure(c,false)
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),1,1,Synchro.NonTunerEx(s.matfilter),1,99)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
    e2:SetCost(s.descost)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)


    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
	
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.pencon2)
	e5:SetOperation(s.penop2)
	c:RegisterEffect(e5)
end

function s.pencon2(e,tp,eg,ep,ev,re,r,rp)
    if (r&REASON_EFFECT)==0 then return false end
	local c=e:GetHandler()
    local rc=re:GetHandler()
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsFaceup() and (rc and (rc:IsSetCard(0xc8) or rc:IsCode(79555535)))
end

function s.penop2(e,tp,eg,ep,ev,re,r,rp)
	local igknight1=Duel.CreateToken(tp, NORMAL_IGKNIGHTS[Duel.GetRandomNumber(1,#NORMAL_IGKNIGHTS)])
    Duel.SendtoExtraP(igknight1, tp, REASON_RULE)
    local igknight2=Duel.CreateToken(tp, NORMAL_IGKNIGHTS[Duel.GetRandomNumber(1,#NORMAL_IGKNIGHTS)])
    Duel.SendtoExtraP(igknight2, tp, REASON_RULE)

    Duel.RemoveCards(e:GetHandler())
end


function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0 end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g=tg:Select(tp, 1,1, nil)
	if Duel.Destroy(g,REASON_EFFECT)~=0 and e:GetHandler():IsRelateToEffect(e) then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end


function s.matfilter(c,val,sc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE,sc,sumtype,tp)
end

function s.shufflefilter(c)
    return c:IsFaceup() and c:IsSetCard(0xc8) and c:IsAbleToDeckAsCost()
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shufflefilter, tp, LOCATION_EXTRA, 0, 2, nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.shufflefilter,tp,LOCATION_EXTRA,0,2,2,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)

end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
	end
end
