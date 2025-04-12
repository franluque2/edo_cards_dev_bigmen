--Techminator Coordinator
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_TECHMINATOR),2,2)

   --choose battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)

    
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_TECHMINATOR_IGNITION)

    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(function(_,_,_,ep) Duel.RegisterFlagEffect(ep,id,RESET_PHASE|PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
	end)

	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not (re:GetHandler():IsSetCard(SET_TECHMINATOR) and re:IsMonsterEffect()) end)

end
s.listed_series={SET_TECHMINATOR}


function s.condition(e)
	return Duel.GetFlagEffect(0,id)+Duel.GetFlagEffect(1,id)==0
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)

    --You cannot activate the effects of other "Techminator" monsters the turn you activate this effect
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(function(e) return (Duel.GetCustomActivityCount(id,e:GetHandlerPlayer(),ACTIVITY_CHAIN)>=1) and not Duel.GetFlagEffect(tp, FLAG_TECHMINATOR_OPT_PER_MONSTER)==0 end)
	e1:SetValue(function(e,re,tp) return re:GetHandler():IsSetCard(SET_TECHMINATOR) and re:IsMonsterEffect() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.rightmoretechminatorfilter(c,ogcard)
    return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsInMainMZone(c:GetControler()) and c:GetSequence()>ogcard:GetSequence()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
        for tc in g:Iter() do
            Duel.ReturnToField(tc)
        end
    end
end