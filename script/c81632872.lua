--Caged Spirits (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Apply one of these effects OR both of them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.thfilter(c)
	return c:IsCode(511001381,81632867,81632122,511001382,511004337,511004339,511004327,511004336,511004328) and c:IsAbleToHand()
end
function s.DARKfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(5)
end
function s.cagefilter(c)
	return c:IsLevelBelow(4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.cagefilter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.cagefilter,tp,0,LOCATION_GRAVE,1,nil)
	if not (b1 or b2) then return end
	local both=b1 and b2 and Duel.IsExistingMatchingCard(s.DARKfilter,tp,LOCATION_MZONE,0,1,nil)
	local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)},
			{both,aux.Stringid(id,4)})
	local break_chk=false
	if op&1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
		end
		break_chk=true
	end
	if op&2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local pg=Duel.SelectMatchingCard(tp,s.cagefilter,tp,0,LOCATION_GRAVE,1,1,nil):GetFirst()
		if pg then
			Duel.HintSelection(pg)
			if break_chk then Duel.BreakEffect() end
			if Duel.MoveToField(pg,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
                pg:AddCounter(0x1107,1)
            end
		end
    end
end
