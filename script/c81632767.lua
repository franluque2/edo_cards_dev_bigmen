--The Noodle Mask of Ghost Peppers (CT)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--Atk,def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(800)
	c:RegisterEffect(e3)
    --Cannot be destroyed by the opponent's trap effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end

function s.filter(c)
	return c:IsRace(RACE_PYRO)
end
function s.efilter(e,te)
	return te:IsTrapEffect() and te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end