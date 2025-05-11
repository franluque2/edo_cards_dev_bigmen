--P.K. Gauntlet (CT)
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x1658)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Counter
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.dcon)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
    --Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(id,1)
	e4:SetCost(s.plcost)
	e4:SetTarget(s.pltg)
	e4:SetOperation(s.plop)
	c:RegisterEffect(e4)
end
s.counter_place_list={0x1658}
function s.thfilter(c)
	return (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)) and c:IsAbleToHand()
end
function s.lv5plusmonfilter(c)
	return c:IsCode(312000143) and c:IsFaceup()
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

function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local rc=tc:GetReasonCard()
	return #eg==1 and rc:IsControler(tp) and tc:IsMonster() and tc:IsReason(REASON_BATTLE) and (rc:IsRace(RACE_FIEND) and rc:IsAttribute(ATTRIBUTE_DARK))
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:AddCounter(0x1658,1)
	end
end

function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	e:SetLabel(c:GetCounter(0x1658))
	Duel.SendtoGrave(c,REASON_COST)
end
function s.plfilter(c)
	return (c:IsRace(RACE_FIEND) and c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(5))
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x1658)
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct-1
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,ct,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,ct,ct,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end