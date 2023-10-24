--Space Bud Exploit (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
    and Duel.IsPlayerCanDiscardDeckAsCost(tp,1)
end

function s.cfilter(c)
    return (c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(5)) and c:IsFaceup()
end

function s.Fusion(c)
    return c:IsCode(81632491) and c:IsAbleToHand()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	if Duel.DiscardDeck(tp,1,REASON_COST)<0 then return end
	--Effect
        if Duel.Damage(1-tp, 500, REASON_EFFECT)
		and Duel.IsExistingMatchingCard(s.Fusion,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.Fusion,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end

