--Beautiful Bird Dancer Pavane (CT)

local s,id=GetID()
function s.initial_effect(c)
	-- Mill
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e)return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)end)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():Filter(Card.IsMonster,nil):GetCount()
	if ct>=2 and c:CanBeDoubleTribute(FLAG_DOUBLE_TRIB_WINGEDBEAST) then
		c:AddDoubleTribute(id,s.otfilter,s.eftg,RESETS_STANDARD_PHASE_END,FLAG_DOUBLE_TRIB_WINGEDBEAST)
	end
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_WINGEDBEAST) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsRace(RACE_WINGEDBEAST) and c:IsLevelAbove(7) and c:IsSummonableCard()
end