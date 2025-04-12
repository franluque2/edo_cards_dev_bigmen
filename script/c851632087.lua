--Techminator Recycler
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_TECHMINATOR),2,2)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:GetMutualLinkedGroupCount()>0 end)
	e1:SetValue(1)
	c:RegisterEffect(e1)

    
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.target)
	e2:SetCountLimit(1,id)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_TECHMINATOR_IGNITION)

	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not (re:GetHandler():IsSetCard(SET_TECHMINATOR) and re:IsMonsterEffect()) end)

end
s.listed_series={SET_TECHMINATOR, SET_DIKTAT}


function s.thfilter(c)
	return c:IsSetCard(SET_DIKTAT) and c:IsType(TYPE_SPELL|TYPE_TRAP) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)

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
    local num=Duel.GetMatchingGroupCount(s.rightmoretechminatorfilter, tp, LOCATION_MZONE, 0, e:GetHandler(), e:GetHandler())+1
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,num,nil)
    if #g>0 then
        Duel.BreakEffect()
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)

        for tc in g:Iter() do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_TRIGGER)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end
