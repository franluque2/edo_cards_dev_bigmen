--Shiranui Style Dimension Slashes
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.target)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.tunerfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_TUNER) and c:GetLevel()>0
end
function s.nontunerfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:GetLevel()>0 and not c:IsType(TYPE_TUNER)
end
function s.matfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:GetLevel()>0
end
function s.spfilter(c,e,tp,lv)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_SYNCHRO) and c:GetLevel()==lv
        and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false,POS_FACEUP)
end
function s.rescon(sg,e,tp,mg)
    local tc=sg:FilterCount(Card.IsType,nil,TYPE_TUNER)
    if tc~=1 then return false end
    local nt=#sg-tc
    if nt<1 or nt>2 then return false end
    local lv=sg:GetSum(Card.GetLevel)
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_REMOVED,0,nil)
    if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,3,s.rescon,0) end
    local sg=aux.SelectUnselectGroup(g,e,tp,2,3,s.rescon,1,tp,HINTMSG_TOGRAVE)
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,#sg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
    if #g<2 then return end
    if not s.rescon(g,e,tp,g) then return end
    local lv=g:GetSum(Card.GetLevel)
    local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,lv)
    if #sg==0 then return end
    if Duel.SendtoGrave(g,REASON_EFFECT|REASON_RETURN)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=sg:Select(tp,1,1,nil):GetFirst()
    if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
        sc:CompleteProcedure()
    end
end