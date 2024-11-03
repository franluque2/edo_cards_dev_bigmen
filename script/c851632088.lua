--Techminator Guard
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_TECHMINATOR),2,2)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:GetMutualLinkedGroupCount()>0 end)
	e1:SetValue(function(_,_,r) return r&REASON_BATTLE==REASON_BATTLE end)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)

    
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_TECHMINATOR_IGNITION)

	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not (re:GetHandler():IsSetCard(SET_TECHMINATOR) and re:IsMonsterEffect()) end)

end
s.listed_series={SET_TECHMINATOR}


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsFaceup() end
    --You cannot activate the effects of other "Techminator" monsters the turn you activate this effect
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(function(e) return Duel.GetCustomActivityCount(id,e:GetHandlerPlayer(),ACTIVITY_CHAIN)>=1 end)
	e1:SetValue(function(e,re,tp) return re:GetHandler():IsSetCard(SET_TECHMINATOR) and re:IsMonsterEffect() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.rightmoretechminatorfilter(c,ogcard)
    return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsInMainMZone(c:GetControler()) and c:GetSequence()>ogcard:GetSequence()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	
    local num=Duel.GetMatchingGroupCount(s.rightmoretechminatorfilter, tp, LOCATION_MZONE, 0, e:GetHandler(), e:GetHandler())+1

    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500*num)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
    
end