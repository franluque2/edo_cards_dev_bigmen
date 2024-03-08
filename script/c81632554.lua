--Stone Giant (CT)
local s,id=GetID()
function s.initial_effect(c)
	-- monsters protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.AncientMonster)
	e1:SetCondition(s.indcon)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
end
function s.AncientMonster(e,c)
	return c:IsFaceup() and c:IsCode(511000126, 511000127, 38520918, 511000128, 76232340, 47986555, 32012841)
end

function s.CuntSpells(e,c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end

function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.CuntSpells,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end