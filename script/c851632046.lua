--Frightfur Dragon
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xc3),1,aux.FilterBoolFunctionEx(Card.IsSetCard,0xa9),2)


    --make a card dissapear

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ERASE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.erasecon)
	e1:SetTarget(s.erasetg)
	e1:SetOperation(s.eraseop)
	c:RegisterEffect(e1)


    --Destroy 1 card on the field
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e2)


    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.summcon)
	e3:SetTarget(s.summtg)
	e3:SetOperation(s.summop)
	c:RegisterEffect(e3)
	
end

local edge_imps={73240432,97567736,34566435,61173621,30068120,29280589,34688023}
local fluffals={39246582,66457138,13241004,82896870,3841833,65331686,45215225,98280324,87246309,2729285,38124994,6142488,72413000,81481818}

function s.erasecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
	--Activation legality
function s.erasetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and not chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ERASE,g,1,0,0)
end
	--Erase 1 card your opponent controls
function s.eraseop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetLabelObject(tc)
        e1:SetCountLimit(1)
		e1:SetOperation(s.flipop3)
		Duel.RegisterEffect(e1,tp)

        Duel.RemoveCards(tc)

    end
end

function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,id)
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		if ft2>0 then
        local tc=e:GetLabelObject()
        local pos=tc:GetPreviousLocation()
        local position=tc:GetPreviousPosition()

        Duel.MoveToField(tc, 1-tp, 1-tp, pos, position, true, nil)

	end

end


function s.cfilter(c)
	return c:IsSetCard({0xc3,0xa9}) and c:IsDiscardable()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ONFIELD,LOCATION_ONFIELD, nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ONFIELD,LOCATION_ONFIELD, nil)
    if not #g>0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local tc=g:Select(tp, 1,1,nil)
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end



function s.summcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end

function s.summtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and Card.IsCanBeSpecialSummoned(e:GetHandler(), e, SUMMON_TYPE_SPECIAL, tp, true, true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function s.summop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetLocationCount(tp, LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)) then return end

    local edgimp=Duel.CreateToken(tp, edge_imps[Duel.GetRandomNumber(1,#edge_imps)])

    local fluffal=Duel.CreateToken(tp, fluffals[Duel.GetRandomNumber(1,#fluffals)])

    Duel.SpecialSummonStep(edgimp, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
    Duel.SpecialSummonStep(fluffal, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)

    Duel.SpecialSummonComplete()
end