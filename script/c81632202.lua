--Dizzy Angel (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_RECOVER)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_DAMAGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end

function s.efilter(e,re)
	return re:GetOwner():IsCode(100000323)
end


function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and (r&REASON_EFFECT)~=0 and re:GetHandler():IsCode(100000320)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp, 500, REASON_EFFECT)
end
