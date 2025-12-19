--Brahma the Sky Star
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- If this card is sent to the GY by a card effect: You can Special Summon 1 EARTH Warrior monster from your Hand or GY. You can only use each effect of "Brahma the Sky Star" once per turn.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_EFFECT~=0 end)
    e2:SetTarget(s.spwarrtarget)
    e2:SetOperation(s.spopwarr)
    c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and not c:HasLevel() end, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_NEGATE,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.negfilter(c)
    return c:IsFaceup() and c:IsNegatableMonster() and not c:HasLevel()
end

function s.revfilter(c)
   return c:IsLevel(5) and c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    if not Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_HAND, 0, 1, nil) then return end
    if Duel.IsExistingMatchingCard(s.negfilter, tp, 0, LOCATION_MZONE, 1, nil)
        and Duel.IsPlayerCanDraw(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil)
        if #g==0 then return end
        Duel.ConfirmCards(1-tp,g)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
        local ng=Duel.SelectMatchingCard(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
        if #ng>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESETS_STANDARD)
            ng:GetFirst():RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESETS_STANDARD)
            ng:GetFirst():RegisterEffect(e2)

            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end

function s.spwarrfilter(c,e,tp)
    return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spwarrtarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spwarrfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spopwarr(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spwarrfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end