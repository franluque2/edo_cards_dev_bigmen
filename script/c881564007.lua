--Fated to Burn in their Ideals
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,TIMING_STANDBY_PHASE|TIMINGS_CHECK_MONSTER)
    e1:SetCost(s.spcost)
	c:RegisterEffect(e1)

    --You can activate this card the turn it was set by revealing a "Fated Chant" in your Hand. 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetValue(function(e) e:SetLabel(1) end)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.spcostfilter,e:GetHandlerPlayer(),LOCATION_HAND,0,1,nil,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)

    --When your opponent activates a card or effect while this card is already face-up on the field: You can reveal a card with the same name in your hand or Extra Deck, negate the activation.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and e:GetHandler():IsFaceup() and Duel.IsChainDisablable(ev) end)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtarg)
    e3:SetOperation(s.negoper)
    c:RegisterEffect(e3)


    --You can send this card from your Field to the GY, then reveal a "Fated Chant" in your Hand; apply that card's effect.
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e4:SetCost(s.copycost)
    e4:SetTarget(s.copytarg)
    e4:SetOperation(s.copyoper)
    c:RegisterEffect(e4)

    
    
end
s.listed_names={CARD_FATED_CHANT}

function s.spcostfilter(c)
    return c:IsCode(CARD_FATED_CHANT) and not c:IsPublic()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp, g)
	end
end

function s.negtarg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negoper(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,re:GetHandler():GetCode()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,re:GetHandler():GetCode())
    Duel.ConfirmCards(1-tp, g)
end

function s.negcostfilter(c,code)
    return c:IsCode(code) and not c:IsPublic()
end

function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
        and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,nil)
    e:SetLabel(g:GetFirst():GetOriginalCode())
    Duel.ConfirmCards(1-tp, g)
end

function s.copytarg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.copyoper(e,tp,eg,ep,ev,re,r,rp)
    local code=e:GetLabel()
    if not code then return end
    local card=Duel.CreateToken(tp, code)
    if card and card:CheckActivateEffect(true,true,false)~=nil then
        local tpe=card:GetType()
        local te=card:GetActivateEffect()
        local tg=te:GetTarget()
        local op=te:GetOperation()
        e:SetCategory(te:GetCategory())
        e:SetProperty(te:GetProperty())
        Duel.ClearTargetCard()
        Duel.Hint(HINT_CARD,0,code)
        if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
        Duel.BreakEffect()
        if op then op(te,tp,eg,ep,ev,re,r,rp) end
    end
end