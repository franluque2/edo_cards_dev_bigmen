--Star Dart Striker
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_RELEASE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c,tp) return c:IsDart() and c:IsControler(tp) end,1,nil,tp)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(c) return c:IsDart() and c:IsFaceup() end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
end
function s.revfilter(c,e,tp)
    return c:IsDart() and not c:IsCode(id) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_HAND, 0, 1, nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    e:SetLabelObject(g:GetFirst())
    g:GetFirst():CreateEffectRelation(e)
    Duel.ConfirmCards(1-tp,g)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsReleasableByEffect() 
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.Release(c,REASON_EFFECT)==0 then return end
    local tc=e:GetLabelObject()
    if not tc:IsRelateToEffect(e) then return end
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end