--P.K. Chaos Shield (CT)
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Def up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsPosition,POS_DEFENSE))
    e2:SetCondition(s.rmcon)
	e2:SetValue(function(_,c) return c:GetBaseAttack()/2 end)
	c:RegisterEffect(e2)
    --Monsters you control cannot be destroyed by your opponent's card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsPosition,POS_DEFENSE))
    e3:SetCondition(s.rmcon)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
    --If castle you control would be destroyed by card effect, you can send this card to the GY instead
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,0})
	e4:SetTarget(s.reptg)
	e4:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	e4:SetOperation(function(e) Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT|REASON_REPLACE) end)
	c:RegisterEffect(e4)
    --Destruction replacement
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.reptg2)
	e5:SetValue(s.repval)
	e5:SetOperation(s.repop)
	c:RegisterEffect(e5)
end
function s.setfilter(c)
	c=e:GetHandler()
	return (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)) and c:IsDefensePos()
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(s.lv5plusmonfilter,0,LOCATION_ONFIELD,0,1,nil)
end
function s.lv5plusmonfilter(c)
	return c:IsCode(312000143) and c:IsFaceup()
end
function s.repfilter(c,tp)
	return c:IsCode(312000143) and c:IsFaceup() and c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end

function s.repfilter2(c,tp)
	return c:IsFaceup() and (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter2,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter2(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
end