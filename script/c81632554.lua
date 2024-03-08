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
	e1:SetValue(1)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCondition(s.condition)
    e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.CuntSpells,tp,LOCATION_SZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
end
function s.AncientMonster(e,c)
	return c:IsFaceup() and c:IsCode(511000126, 511000127, 38520918, 511000128, 76232340, 47986555, 32012841)
end

function s.CuntSpells(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end

function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.CuntSpells,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end