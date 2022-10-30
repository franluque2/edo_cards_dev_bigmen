--Vast Outer Space (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.con)
	c:RegisterEffect(e1)
	--Decrease ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.target)
	e2:SetValue(-700)
	c:RegisterEffect(e2)
	--Decrease DEF
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetValue(160202046)
	c:RegisterEffect(e3)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(aux.FaceupFilter(Card.IsCode, 160202046),e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)>0
end

function s.target(_,c)
	return not (c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_DARK))
end
