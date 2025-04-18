--Perfect Tractiger
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed by battle while "Pierce!" in GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE+EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.con1)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Cannot be destroyed by card effect while "Pierce!" in GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con1)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Triple Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(2)
	c:RegisterEffect(e3)
end
s.listed_names={160001037}
function s.cfilter(c)
	return c:IsCode(160001037)
end
function s.con1(e)
	local tp=e:GetHandler():GetControler()
	 return e:GetHandler():IsAttackPos()
		and Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function s.atkcon(e)
	local tp=e:GetHandler():GetControler()
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil)
end