--Jade Knight - Twin Lasers
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end
s.listed_names={id,10992251} -- Gradius

function s.spfilter1(c,e,tp)
    return c:IsCode(10992251) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter2(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
        and c:GetAttack()==1200 and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local op=e:GetHandler():GetOwner()
    local b1=Duel.IsExistingMatchingCard(s.spfilter1,op,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,op) and Duel.IsExistingMatchingCard(s.spfilter2,op,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,2,nil,e,op) and Duel.GetLocationCount(op,LOCATION_MZONE)>1
        and not Duel.IsPlayerAffectedByEffect(op, CARD_BLUEEYES_SPIRIT)
    local b2=Duel.GetLocationCount(1-op,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,1-op,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,0,1-op,false,false)
    local ops={}
	local opval={}
	local off=1
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	local op2=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op2]
    e:SetLabel(sel)
    if sel==1 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,op,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    elseif sel==2 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-op,LOCATION_HAND+LOCATION_EXTRA)
    else
        e:SetLabel(0)
    end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetHandler():GetOwner()
    local sel=e:GetLabel()
    if sel==1 then
        if Duel.GetLocationCount(op,LOCATION_MZONE)<=1 then return end
        Duel.Hint(HINT_SELECTMSG,op,HINTMSG_SPSUMMON)
        local g1=Duel.SelectMatchingCard(op,s.spfilter1,op,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,op)
        Duel.Hint(HINT_SELECTMSG,op,HINTMSG_SPSUMMON)
        local g2=Duel.SelectMatchingCard(op,s.spfilter2,op,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,op)
        g1:Merge(g2)
        if #g1>0 then
            Duel.SpecialSummon(g1,0,op,op,false,false,POS_FACEUP)
            --cannot special summon except LIGHT Machine monsters
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetDescription(aux.Stringid(id,3))
            e1:SetReset(RESET_PHASE+PHASE_END)
            e1:SetTargetRange(1,0)
            e1:SetLabel(op)
            e1:SetTarget(s.splimit)
            Duel.RegisterEffect(e1,op)
        end
    elseif sel==2 then
        if Duel.GetLocationCount(1-op,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,1-op,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(1-op,Card.IsCanBeSpecialSummoned,1-op,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,0,1-op,false,false)
        if #g>0 then
            local tc=g:GetFirst()
            Duel.SpecialSummonStep(tc,0,1-op,1-op,false,false,POS_FACEUP)
            --Negate effects
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            --Banish when leaves field
            local e3=Effect.CreateEffect(e:GetHandler())
		    e3:SetDescription(3300)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            e3:SetValue(LOCATION_REMOVED)
            tc:RegisterEffect(e3)
            Duel.SpecialSummonComplete()
        end
    else
    end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return sump==e:GetLabel() and not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE))
end