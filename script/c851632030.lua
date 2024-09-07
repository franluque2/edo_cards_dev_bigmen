--Arachne, Spiderite Broodmother
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),1,1,Synchro.NonTuner(nil),2,99)
	c:EnableReviveLimit()

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.hspcon)
	e0:SetTarget(s.hsptg)
	e0:SetOperation(s.hspop)
	e0:SetCountLimit(1,{id,3})
	c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_CONJURE+CATEGORY_REMOVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.bancon)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}

function s.tohandfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHandAsCost()
end

function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.tohandfilter, tp, LOCATION_MZONE, 0,1, nil)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectMatchingCard(tp,s.tohandfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil)
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
	Duel.SendtoHand(g, tp, REASON_COST+REASON_MATERIAL)
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



function s.spspiderop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, CARD_SPIDERITELING, SET_SPIDERITE, TYPE_NORMAL, 0, 0, 1, RACE_INSECT, ATTRIBUTE_LIGHT) then
		local Spideriteling=WbAux.GetSpideriteling(tp)
		Duel.SpecialSummon(Spideriteling, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
	end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,3),nil)
end

function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT)
end

function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,3),nil)

    local num=Duel.GetLocationCount(tp, LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then num=0 end
	if num<2 then return end

	local Spideriteling1=WbAux.GetSpideriteling(tp)
	Duel.SpecialSummonStep(Spideriteling1, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
	local Spideriteling2=WbAux.GetSpideriteling(tp)
	Duel.SpecialSummonStep(Spideriteling2, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
	Duel.SpecialSummonComplete()

end