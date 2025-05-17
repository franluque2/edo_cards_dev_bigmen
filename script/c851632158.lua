--Kumori, Spiderite Empress
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    c:EnableReviveLimit()
	c:SetSPSummonOnce(id)

    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),2,nil,s.matcheck)

    	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.hspcon)
	e0:SetTarget(s.hsptg)
	e0:SetOperation(s.hspop)
	e0:SetCountLimit(1,{id,3})
	c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_CONJURE+CATEGORY_REMOVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.adcon1)
    e1:SetTarget(s.tarfunc)
	e1:SetOperation(s.adop1)
	c:RegisterEffect(e1)

    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return (c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)) end)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e2:SetTarget(s.thtgtg)
	e2:SetOperation(s.thtgop)
	c:RegisterEffect(e2)


	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateActivation(ev) end)
	c:RegisterEffect(e3)


end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}


function s.matfilter(c,lc,sumtype,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT,lc,sumtype,tp) and c:IsRace(RACE_INSECT,lc,sumtype,tp)
end

function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp)
end



function s.tobanishfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end

function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.tobanishfilter, tp, LOCATION_GRAVE, 0,1, nil)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectMatchingCard(tp,s.tobanishfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Remove(g, POS_FACEUP, REASON_COST+REASON_MATERIAL)
	c:SetMaterial(g)
	c:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD, 0, 0)
	g:DeleteGroup()

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetOperation(s.retop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1,true)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(3206)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
    c:RegisterEffect(e2,true)
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end

function s.adcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0 and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0
end

function s.tarfunc(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not (c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)end

function s.adop1(e,tp,eg,ep,ev,re,r,rp)
    local Spideriteling=WbAux.GetSpideriteling(tp)

	local Spideriteling2=WbAux.GetSpideriteling(tp)
    local g=Group.CreateGroup()
    g:AddCard(Spideriteling)
    g:AddCard(Spideriteling2)
    Duel.SendtoHand(g, tp, REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
end


function s.thfilter(c)
	return c:IsSetCard(SET_SPIDERITE) and c:IsAbleToHand()
end
function s.thtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not (c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thtgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end



function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsMonsterEffect()
		and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.costfilter(c)
	return c:IsCode(CARD_SPIDERITELING) and c:IsAbleToRemoveAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>=1 end
	local rg=g:Select(tp, 1,1,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not (c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end