--Beautiful Bird Wing (CT)
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,nil,s.eqfilter,s.eqlimit)
	--atk/def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetCondition(s.birdfilter)
	c:RegisterEffect(e2)
end
function s.eqfilter(c)
	return c:IsFaceup() and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.condition(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsAttribute(ATTRIBUTE_WIND)
end