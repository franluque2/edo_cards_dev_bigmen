--Jealous Brahm the Cubic Ascendant
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    	--Link summon
	Link.AddProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(s.pencon)
	e6:SetTarget(s.pentg)
	e6:SetOperation(s.penop)
	c:RegisterEffect(e6)


end

s.listed_series={0xe3}
s.counter_place_list={0x1038}


function s.matfilter(c,lc,sumtype,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xe3,lc,sumtype,tp)
end


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase()
end
function s.spcfilter(c,e,tp)
	return c:IsSetCard(0xe3) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD)>0 and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil,e,tp,c:GetOriginalLevel(), c:GetOriginalRace()) and c:GetBattledGroupCount()>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.spcfilter,1,false,nil,c,e,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.spcfilter,1,1,false,nil,c,e,tp)
	Duel.Release(g,REASON_COST)
    e:SetLabelObject(g:GetFirst())
end
function s.spfilter(c,e,tp,lvl,race)
	return c:IsSetCard(0xe3) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsLevel(lvl+1) and c:IsRace(race)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetOriginalLevel(), tc:GetOriginalRace())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)

        local tc2=g:GetFirst()
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_SET_ATTACK)
        e3:SetValue((tc2:GetOriginalLevel()-1)*1000)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
        tc2:RegisterEffect(e3)
    
	end
end



function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_SZONE)>0 end
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetLocationCount(tp, LOCATION_SZONE)>0) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)

        local e1=Effect.CreateEffect(c)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
        e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
        c:RegisterEffect(e1)

        
        local e2=Effect.CreateEffect(c)
        e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
        e2:SetType(EFFECT_TYPE_QUICK_O)
        e2:SetCode(EVENT_FREE_CHAIN)
        e2:SetRange(LOCATION_SZONE)
        e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
        e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
        e2:SetTarget(s.sptg2)
        e2:SetOperation(s.spop2)
        c:RegisterEffect(e2)
	end
end

function s.takecontrolfilter(c)
    return c:IsControlerCanBeChanged() and c:IsFaceup() and c:GetCounter(0x1038)>0
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.takecontrolfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.takecontrolfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.takecontrolfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)

end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
            local tc=Duel.GetFirstTarget()
            if tc and tc:IsRelateToEffect(e) then
                if Duel.GetControl(tc,tp,0,1) then
                    Duel.BreakEffect()
                    tc:RemoveCounter(tp, 0x1038, tc:GetCounter(0x1038), REASON_EFFECT)
                end
            end
        end
	end
end