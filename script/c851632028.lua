--Spiderite's Protective Instincts
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
		--Activate
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,0))
        e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
        e1:SetType(EFFECT_TYPE_ACTIVATE)
        e1:SetCode(EVENT_CHAINING)
        e1:SetCondition(s.condition)
        e1:SetCost(s.cost)
        e1:SetTarget(s.target)
        e1:SetOperation(s.activate)
        e1:SetCountLimit(1,{id,0})
        c:RegisterEffect(e1)

        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(id,1))
        e2:SetCategory(CATEGORY_TOGRAVE)
        e2:SetType(EFFECT_TYPE_QUICK_O)
        e2:SetRange(LOCATION_GRAVE)
        e2:SetCode(EVENT_FREE_CHAIN)
        e2:SetCondition(aux.exccon)
        e2:SetCost(aux.bfgcost)
        e2:SetTarget(s.target2)
        e2:SetOperation(s.activate2)
        e2:SetCountLimit(1,{id,1})
        c:RegisterEffect(e2)
end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}

function s.sendspideritelingfilter(c)
    return c:IsCode(CARD_SPIDERITELING) and c:IsAbleToGrave()
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sendspideritelingfilter, tp, LOCATION_DECK, 0, 1, nil) and Duel.IsMainPhase() and Duel.IsTurnPlayer(tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sendspideritelingfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end

end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SPIDERITE) and c:IsReleasable() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.fuspideritelingfilter(c)
    return c:IsFaceup() and c:IsCode(CARD_SPIDERITELING)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil) and Duel.IsExistingMatchingCard(s.fuspideritelingfilter, tp, LOCATION_ONFIELD, 0, 1, nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateActivation(ev) then return end
	if re:GetHandler():IsRelateToEffect(re) then
    Duel.Destroy(eg,REASON_EFFECT)
    end

end
