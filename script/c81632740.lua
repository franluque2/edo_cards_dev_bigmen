--Stegocutter
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--atk/def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--level up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetValue(3)
	c:RegisterEffect(e3)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
