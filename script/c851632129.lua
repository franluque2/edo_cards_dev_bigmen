--Sunken Lullaby
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
    e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)


end
s.listed_names={CARD_ABYSSAL_DREDGE}


function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return WbAux.CanPlayerSummonDredge(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_ABYSSAL_DREDGE,nil,TYPE_MONSTER+TYPE_EFFECT,0,0,4,RACE_REPTILE,ATTRIBUTE_DARK,POS_FACEUP,tp,0) then return end
    local dredge=Duel.CreateToken(tp, CARD_ABYSSAL_DREDGE)
    if not Duel.SpecialSummon(dredge, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP) then return end
    Duel.BreakEffect()
    local atk=Card.GetAttack(dredge)
	if atk>2000 and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return WbAux.CanPlayerSummonDredge(tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not WbAux.CanPlayerSummonDredge(tp) then return end
    WbAux.SpecialSummonDredge(tp,POS_FACEUP)
end