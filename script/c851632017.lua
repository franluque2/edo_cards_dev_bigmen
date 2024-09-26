--Igknight Knave
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOEXTRA+CATEGORY_CONJURE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)


	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spsynccon)
	e3:SetTarget(s.spsynctg)
	e3:SetOperation(s.spsyncop)
	c:RegisterEffect(e3)

    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

end


s.listed_series={0xc8}


function s.spsynccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and (Duel.GetTurnPlayer()~=tp) and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0
end
function s.desfilter(c)
	return c:HasLevel() and c:IsDestructable()
		and c:IsFaceup()
end
function s.spfilter(c,e,tp,matg,lv)
	return (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_DRAGON)) and c:IsType(TYPE_SYNCHRO)
		and c:IsLevel(lv) and Duel.GetLocationCountFromEx(tp,tp,matg,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsContains(e:GetHandler())
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg,sg:GetSum(Card.GetLevel))
end

function s.syncfilter(c, tc)
	return Card.IsSynchroSummonable(c,tc) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.spsynctg(e,tp,eg,ep,ev,re,r,rp,chk)

	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)

	
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.spsyncop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(s.syncfilter,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end

end

function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xc8) and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)

end

function s.splimit(e,c)
	return not s.counterfilter(c)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #dg<2 then return end
	local num=Duel.Destroy(dg,REASON_EFFECT)
    if num==0 then return end
	if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
		local token1=WbAux.GetNormalIgknight(tp)
		Duel.SendtoHand(token1, tp, REASON_EFFECT)

		local token2=WbAux.GetNormalIgknight(tp,token1)
        Duel.SendtoExtraP(token2, tp, REASON_EFFECT)
	end
end
