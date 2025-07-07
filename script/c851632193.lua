--The Seventh Barians
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.actcon)
    e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)


    local e2=e1:Clone()
    e2:SetCondition(s.actcon2)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    c:RegisterEffect(e2)


    	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.gycost)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)


end
local CARD_BARIAN_HOPE=67926903

s.listed_series={SET_NUMBER}
s.listed_names={CARD_BARIAN_HOPE}



function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NUMBER),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and not Duel.IsExistingMatchingCard(aux.FaceupFilter(s.confilter),tp,LOCATION_MZONE,0,1,nil)
end

function s.confilter(c)
	if not c:IsType(TYPE_XYZ) then return false end
	local no=c.xyz_number
	return (c:IsSetCard(SET_NUMBER) and no and no>=101 and no<=107)
		or c:GetOverlayGroup():IsExists(s.confilter,1,nil)
end

function s.actcon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(s.confilter),tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NUMBER),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.spfilter(c,e,tp,costc)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_XYZ)
	return #pg<=0 and c:IsCode(CARD_BARIAN_HOPE) and c:IsType(TYPE_XYZ)
		and Duel.GetLocationCountFromEx(tp,tp,costc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cost_chk=e:GetLabel()==1
		e:SetLabel(0)
		return cost_chk or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
        Duel.BreakEffect()
        local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,LOCATION_MZONE,sc)
        if #g>0 then
            Duel.Overlay(sc,g,true)
        end
	end
end


function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.PayLPCost(tp,Duel.GetLP(tp)//2)
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end


function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCode(CARD_BARIAN_HOPE) and c:GetOverlayGroup():IsExists(s.nmbrfilter,1,nil)
end

function s.nmbrfilter(c)
	local no=c.xyz_number
	return c:IsSetCard(SET_NUMBER) and no and c:IsType(TYPE_EFFECT)
end

function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_XYZ) and s.xyzfilter(tc) then
        for mat in tc:GetOverlayGroup():Iter() do
            if s.nmbrfilter(mat) then
                tc:CopyEffect(mat:GetOriginalCode(),RESETS_STANDARD_PHASE_END,1)
            end
        end
        --string hint
        tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_TURN_SET+RESET_LEAVE+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
        tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_PHASE+PHASE_END)
        e3:SetCountLimit(1)
        e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e3:SetLabelObject(tc)
        e3:SetCondition(s.rmcon)
        e3:SetOperation(s.rmop)
        Duel.RegisterEffect(e3,tp)
	end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end