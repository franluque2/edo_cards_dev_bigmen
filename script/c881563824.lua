--Create New World
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)

	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)

end

function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and not (re:GetHandler():IsSetCard(SET_MINECRAFT) or re:GetHandler():IsRace(RACE_ROCK)))
end

function s.aclimit(e,re,tp)
	return re:IsMonsterEffect() and not (re:GetHandler():IsSetCard(SET_MINECRAFT) or (re:GetHandler():IsRace(RACE_ROCK)))
end

s.listed_series={SET_MINECRAFT}
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_DECK,0,nil,RACE_ROCK)
		return aux.SelectUnselectGroup(g,e,tp,5,5,nil,chk)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_DECK,0,nil,RACE_ROCK)
	local rg=aux.SelectUnselectGroup(g,e,tp,5,5,nil,1,tp,aux.Stringid(id,1))
	if #rg>0 then
		Duel.ConfirmCards(1-tp,rg)
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(rg)
		Duel.SortDecktop(tp,tp,#rg)
	end
end


function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_MINECRAFT) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end