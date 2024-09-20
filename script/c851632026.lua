--Spiderite Breakfast Break
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

    --search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,0})
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.sendtg)
    e4:SetCost(s.sendcost)
	e4:SetOperation(s.sendop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_CONJURE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptar)
	e2:SetOperation(s.activate2)
	e2:SetCountLimit(1,{id,2})
	--c:RegisterEffect(e2)
	
end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}

function s.lvfilter(c,tp)
	return c:IsFaceup() and c:HasLevel() and c:IsLevelBelow(Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,CARD_SPIDERITELING), tp, LOCATION_REMOVED, LOCATION_REMOVED, nil))
end
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg and #eg==1 and eg:IsExists(s.lvfilter,1,nil,tp) end
end
function s.sendcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Card.IsAbleToGraveAsCost(e:GetHandler()) end
	Duel.SendtoGrave(e:GetHandler(), REASON_COST)
end
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SendtoGrave(eg, REASON_EFFECT) then
        Duel.BreakEffect()
        local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,CARD_SPIDERITELING), tp, LOCATION_REMOVED, LOCATION_REMOVED, nil)
        Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp, Card.IsCode, 1, false, false, nil, CARD_SPIDERITELING) end
    local max=Duel.GetMatchingGroupCount(s.thfilter, tp, LOCATION_DECK, 0, nil)
	local rg=Duel.SelectReleaseGroupCost(tp,Card.IsCode,1,max,false,nil,nil,CARD_SPIDERITELING)
	e:SetLabel(#rg)
	Duel.Release(rg,REASON_COST)

end
function s.thfilter(c)
	return c:IsSetCard(SET_SPIDERITE) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    local num=e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,num,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
    local num=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,num,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end



function s.sptar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and
         Duel.IsPlayerCanSpecialSummonMonster(tp, CARD_SPIDERITELING, SET_SPIDERITE, TYPE_MONSTER+TYPE_NORMAL, 0, 0, 1, RACE_INSECT, ATTRIBUTE_LIGHT) end
end

function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local spideriteling=WbAux.GetSpideriteling(tp)
    Duel.SpecialSummon(spideriteling, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
end