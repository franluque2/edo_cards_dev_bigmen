--Taking Aim...
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon 1 Level 6 or lower "Dart" monster from your hand. 
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)



    --If a monster Special Summoned by this card's effect is Tributed: You can banish this card from your GY, then target 1 monster your opponent controls; destroy it.

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_RELEASE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.descon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end
-- c:isdart checks dart monsters

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(function(c,e,tp) return c:IsDart() and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,function(c,e,tp) return c:IsDart() and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
        g:GetFirst():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_EXC_GRAVE-RESET_TODECK,0,1,e:GetHandler():GetCardID())
        g:GetFirst():RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
        Duel.SpecialSummonComplete()
    end
end

function s.sumfilter(c,e,tp)
    local res=c:GetFlagEffect(id)~=0 and c:GetFlagEffectLabel(id)==e:GetHandler():GetCardID()
    if res then
        c:ResetFlagEffect(id)
        return true
    end
    return false
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.sumfilter,1,nil,e,tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

