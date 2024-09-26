--White Cat with Dark Tail (CT)
local s,id=GetID()
function s.initial_effect(c)
	--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.thfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.Manga(c)
	return c:IsCode(81632751, 81632754, 81632755)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():GetFirst()
	if ct:IsMonster() and ct:IsRace(RACE_BEAST) and ct:IsAttribute(ATTRIBUTE_WATER) then
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
            if Duel.IsExistingMatchingCard(s.Manga,tp,LOCATION_GRAVE,0,1,nil) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
		end
	end
end
