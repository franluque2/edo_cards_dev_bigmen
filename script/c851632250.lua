--Chemicritter Phos Peacock
local s,id=GetID()
function s.initial_effect(c)
    Gemini.AddProcedure(c)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(Cost.SelfDiscard)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- While this card is a Normal monster on the field, you can Normal Summon it to have it become an Effect Monster with these effects:

    --Once per turn: You can, immediately after this effect resolves, Normal Summon 1 Gemini Monster.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(Gemini.EffectStatusCondition)
    e2:SetTarget(s.nstarg)
    e2:SetOperation(s.nsoper)
    c:RegisterEffect(e2)

    -- Your opponent cannot target Gemini Monsters or "Catalyst Field" you control with card effects.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_ONFIELD,0)
    e3:SetCondition(Gemini.EffectStatusCondition)
    e3:SetTarget(function(e,c) return c:IsFaceup() and ((c:IsType(TYPE_GEMINI) and c:IsMonster()) or c:IsCode(65959844)) end)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
end
s.listed_names={id, 65959844} --Catalyst Field
s.listed_card_types={TYPE_GEMINI}

function s.spfilter(c,e,tp)
    return c:IsType(TYPE_GEMINI) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if not tc then return end
    if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
        tc:EnableGeminiStatus()
    end
    Duel.SpecialSummonComplete()
end

function s.nsfilter(c)
    return c:IsType(TYPE_GEMINI) and c:IsSummonable(true,nil)
end

function s.nstarg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
end

function s.nsoper(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
    if tc then
        Duel.Summon(tp,tc,true,nil)
    end
end