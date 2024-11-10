--Diktat of Repurposing
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

end
s.listed_series={SET_TECHMINATOR}

function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_MACHINE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.tohandfilter, tp, LOCATION_GRAVE, 0, nil)

    if chk==0 then return #g>0 or WbAux.CanPlayerSummonTechminator(tp) and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0 end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)

end

function s.tohandfilter(c)
    return c:IsReason(REASON_DISCARD) and c:GetTurnID()==Duel.GetTurnCount() and c:GetReasonEffect() and c:GetReasonEffect():GetHandler():IsSetCard({SET_TECHMINATOR,SET_DIKTAT})
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.tohandfilter, tp, LOCATION_GRAVE, 0, nil)
    if #g>0 then
        Duel.SendtoHand(g, tp, REASON_EFFECT)
    end
    WbAux.CreateDiktatSummonEffect(e,tp,eg,ep,ev,re,r,rp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalRace(RACE_MACHINE)
end