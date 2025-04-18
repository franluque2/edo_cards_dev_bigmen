--Graydle Ambush
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
end
s.listed_series={0xd1}

function s.filter(c,e,tp)
	return c:IsSetCard(0xd1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,2,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK|LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.scfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsSynchroSummonable(nil)
end

function s.spfilter(c)
	return c:IsLinkSummonable() and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,2,2,nil)
		local tc1=sg:GetFirst()
        local tc2=sg:GetNext()
        local fid=e:GetHandler():GetFieldID()
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		tc1:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc2:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		Duel.SpecialSummonComplete()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		Duel.RegisterEffect(e1,tp)

        Duel.BreakEffect()
        local syg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil)
        local lincg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil)
        if #syg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0))  then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sc=syg:Select(tp,1,1,nil):GetFirst()
            if sc then
                Duel.SynchroSummon(tp,sc,nil)
            end
        elseif #lincg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local lc=lincg:Select(tp,1,1,nil):GetFirst()
            if lc then
                Duel.LinkSummon(tp,lc)
            end
        end
        end
end

function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	Duel.Destroy(tg,REASON_EFFECT)
end
