--Beautiful Bird Lord and Lady (CT)
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,81632773,81632770)
	--Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WINGEDBEAST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.DiscardDeck(tp,4,REASON_EFFECT)
	--gy recover
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	local th=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	if #th>0 then
		Duel.SendtoHand(th,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,th)
        if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,3,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,3,3,nil)
            Duel.HintSelection(tg,true)
            Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
        end
	end
end