--IPC Order: New Market Opportunity
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target2)
	e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
    local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)

    if #g<1 then return end
    local sg=g:Filter(Card.IsCode,nil,ac)
    if #sg>0 then
        --banish until the end phase
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
        sg:KeepAlive()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetOperation(s.retop)
        e1:SetLabelObject(sg)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local sg=e:GetLabelObject()
    Duel.SendtoHand(sg, 1-tp, REASON_RULE+REASON_TEMPORARY)
    Group.DeleteGroup(sg)
end

function s.filter(c)
	return c:IsSetCard(SET_IPC) and c:IsAbleToHand()
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
