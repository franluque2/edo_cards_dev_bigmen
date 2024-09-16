--Frieslas Hausrezept (Friesla's Home Recipe)
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetCondition(function(e) return e:GetHandler():IsCode(30243636) end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.listed_names={30243636}


function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.thfilter(c)
	return (c:IsSetCard({SET_FRIESLA,SET_RECIPE}) and not c:IsCode(id))
		and c:IsAbleToHand()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsSetCard,nil,SET_FRIESLA)>=1 and sg:FilterCount(Card.IsSetCard,nil,SET_RECIPE)>=1
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g<2 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #rg>0 then
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,rg)
	end
    local e1=WbAux.CreateFrieslaAttachEffect(e:GetHandler())
    Duel.RegisterEffect(e1, tp)
end