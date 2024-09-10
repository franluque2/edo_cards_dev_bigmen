--Mictlantecuhtli
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local sme,soe=Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS)
	sme:SetOperation(s.mretop)
    c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(Card.IsType,TYPE_SPIRIT),1,99,s.matfilter)


    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
	e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.norettg)
	e2:SetTargetRange(LOCATION_MZONE,0)
	c:RegisterEffect(e2)

    aux.GlobalCheck(s,function()
            s.name_list={}

            local ge1=Effect.CreateEffect(c)
            ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            ge1:SetCode(EVENT_PHASE_START+PHASE_END)
            ge1:SetOperation(s.checkop)
            Duel.RegisterEffect(ge1,0)
        end)
end
s.listed_card_types={TYPE_SPIRIT}

function s.norettg(e,c)
	return c~=e:GetHandler()
end

function s.funotspiritmon(c)
    return c:IsFaceup() and not c:IsType(TYPE_SPIRIT)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and not chkc:IsType(TYPE_SPIRIT) end
	if chk==0 then return Duel.IsExistingTarget(s.funotspiritmon,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.funotspiritmon,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_SPIRIT)
		tc:RegisterEffect(e1)

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e2:SetCode(EFFECT_SPSUMMON_CONDITION)
        tc:RegisterEffect(e2)

        tc:RegisterFlagEffect(0,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))

        tc:RegisterFlagEffect(FLAG_SPIRIT_RETURN,0,0,0)


        local sme,soe=Spirit.AddProcedure(tc,EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS,EVENT_FLIP)
        sme:SetOperation(s.mretop2)
        sme:SetTarget(s.mrettg)
        sme:SetLabel(c:GetOwner())

        
	end
end

function s.mrettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    e:SetProperty(0)
    Spirit.MandatoryReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, e:GetLabel(), LOCATION_GRAVE|LOCATION_HAND)
end

function s.spfilter(c,e,tp)
    return c:IsType(TYPE_SPIRIT) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, true, false,POS_FACEUP)
end
function s.mretop2(e,tp,eg,ep,ev,re,r,rp)
	Spirit.ReturnOperation(e,tp,eg,ep,ev,re,r,rp)
	
    local play=e:GetLabel()
    if e:GetHandler():IsLocation(LOCATION_HAND) then
        if Duel.IsExistingMatchingCard(s.spfilter, play, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil, e, tp) and Duel.SelectYesNo(play, aux.Stringid(id, 2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local tc=Duel.SelectMatchingCard(play, s.spfilter, play, LOCATION_HAND+LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
            if tc then
                Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, play, play, true, false, POS_FACEUP)
            end

        end
    end
end


--Can treat a Spirit monster as a Tuner
function s.matfilter(c,scard,sumtype,tp)
    return c:IsType(TYPE_SPIRIT,scard,sumtype,tp)
end

function s.mictfilter(c)
	return c:IsFaceup() and c:IsOriginalCode(id)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.mictfilter, tp, LOCATION_MZONE, 0, nil)

	if #g>0 then
        for i in g:Iter() do
            i:RegisterFlagEffect(FLAG_SPIRIT_RETURN,RESET_PHASE+PHASE_END,0,1)
        end
	end
end

function s.repfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end

function s.mretop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.repfilter, tp, LOCATION_MZONE|LOCATION_GRAVE, 0, e:GetHandler())
	if not (#g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3))) then return Spirit.ReturnOperation(e,tp,eg,ep,ev,re,r,rp) end
	
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=g:Select(tp, 1,1,nil)
    Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)

end