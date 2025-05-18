--Legendary Celtic Guardian
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)

end
s.listed_names={89397517} --Legend of Heart
s.listed_series={SET_CELTIC_GUARD}

function s.thfilter(c)
	return ((c:IsSetCard(SET_CELTIC_GUARD) and not c:IsCode(id)) or c:IsCode(89397517)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end



function s.tdfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_CELTIC_GUARD) and c:IsLevel(4) and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,nil,e,tp)

	if chkc then return false end
	if chk==0 then
		return g:GetClassCount(Card.GetCode)>2
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

local legknightnames={80019195,85800949,84565800} --Legendary Knight Timaeus, Legendary Knight Critias, Legendary Knight Hermos
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
    if not #g==3 then return end
    local i=1
    for tc in g:Iter() do
        Card.Recreate(tc, legknightnames[i], nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
        i = i + 1
    end
    Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
end