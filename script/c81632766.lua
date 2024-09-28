--Noodle Mask of Gluttony (CT)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--Atk,def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
	--Indestructable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetTarget(s.indtg)
	e4:SetValue(s.efilter)
    e4:SetCondition(s.condition2)
	c:RegisterEffect(e4)
end
function s.filter(c)
	return c:IsRace(RACE_PYRO) and c:IsLevelAbove(7)
end

function s.indtg(e,c)
	return c:IsSpellTrap()
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end

function s.condition2(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsType(TYPE_NORMAL)
end