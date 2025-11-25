--Parasite Cocooner
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_TOGRAVE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

	local params = {matfilter=function(c) return c:IsRace(RACE_INSECT) end,extrafil=s.fextra,extraop=s.extraop,extratg=s.extratarget}
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)

end

function s.spfilter(c,e,tp)
    c:AssumeProperty(ASSUME_RACE, RACE_INSECT)
    c:AssumeProperty(ASSUME_ATTRIBUTE, ATTRIBUTE_LIGHT)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
        --cannot special summon except Insect monsters
        local e5=Effect.CreateEffect(c)
        e5:SetDescription(aux.Stringid(id,2))
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e5:SetTargetRange(1,0)
        e5:SetTarget(function(e,c) return not c:IsRace(RACE_INSECT) end)
        e5:SetReset(RESET_PHASE|PHASE_END,2)
        Duel.RegisterEffect(e5,tp)

    if tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
        e1:SetValue(RACE_INSECT)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetValue(ATTRIBUTE_LIGHT)
        tc:RegisterEffect(e2)
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
        Duel.Equip(tp,c,tc,true)
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_EQUIP_LIMIT)
        e4:SetReset(RESET_EVENT|RESETS_STANDARD)
        e4:SetValue(s.eqlimit)
        e4:SetLabelObject(tc)
        c:RegisterEffect(e4)
        end
    end
end

function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end

function s.matremfilter(c)
    return c:IsAbleToRemove() and c:IsRace(RACE_INSECT)
end

function s.checkmat(tp,sg,fc)
	return fc:IsRace(RACE_INSECT) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.matremfilter),tp,LOCATION_GRAVE,0,nil),s.checkmat
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end

function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end