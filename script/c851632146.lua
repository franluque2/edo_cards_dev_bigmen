--Yuanzu, Origin of the Yang Zing
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WYRM),2,2)
	
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

end
s.listed_series={0x9e}


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x9e) and c:HasLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg and sg:FilterCount(Card.IsType,nil,TYPE_TUNER)==1
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
		return ct>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 2, tp, LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.levelfilter(c,e,tp,level)
    return c:IsSetCard(0x9e) and c:IsLevel(level) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD)
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if #sg==0 then return end
	local rg=aux.SelectUnselectGroup(sg,e,tp,2,2,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummon(rg,0,tp,tp,true,false,POS_FACEUP,zone)>0 then
        local totallevels=rg:GetSum(Card.GetOriginalLevel)
        local tc=Duel.GetMatchingGroup(s.levelfilter, tp, LOCATION_EXTRA, 0, nil,e,tp, totallevels)
        if Duel.Destroy(rg, REASON_EFFECT)>0 and #tc>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local sc=tc:Select(tp, 1, 1, nil):GetFirst()
            if sc then
                if Duel.SpecialSummon(sc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP) then
                    sc:CompleteProcedure()
                end
            end
        end
    end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	aux.addTempLizardCheck(c,tp,function(_e,_c) return not (_c:IsOriginalType(TYPE_SYNCHRO) and _c:IsOriginalSetCard(0x9e)) end)
end
function s.splimit(e,c)
	return not (c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x9e)) and c:IsLocation(LOCATION_EXTRA)
end

