--Gemini Egg (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (not Duel.IsPlayerAffectedByEffect(tp,FLAG_NO_TRIBUTE)) and e:GetHandler():CanBeDoubleTribute()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp, 1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--cost
	Duel.DiscardDeck(tp, 1, REASON_COST)
	local c=e:GetHandler()
	c:AddDoubleTribute(id,s.otfilter,s.eftg,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0)
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute() and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsLevelAbove(7) and c:IsSummonableCard()
end
