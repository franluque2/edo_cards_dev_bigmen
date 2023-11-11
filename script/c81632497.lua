--Soul Arms - Avalonia Holder (CT)
--scripted by Bigmen
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)

    --indes
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetCondition(s.indcon)
	e2:SetTarget(s.indtg)
    e2:SetValue(1)
	c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)


end

function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,160011052), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end
function s.indtg(e,c)
	return (c:IsMonster() and c:IsPosition(POS_ATTACK)) or (c:IsCode(160011052) and c:IsFaceup())
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFaceup, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, nil)*100
end

function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHIC) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end