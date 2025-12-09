--Spawning Grounds Scout
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_FLIP)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)

end
s.listed_names={CARD_ABYSSAL_DREDGE, 851632003} --Abyssstal Dredge, Dark Mother of Dredges

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
        and Duel.IsPlayerCanSpecialSummonMonster(tp, 851632003, nil, TYPE_MONSTER+TYPE_EFFECT, 1500, 2000, 4, RACE_REPTILE, ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    if ft>2 then ft=2 end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
    if ft==2 then ft=Duel.AnnounceNumber(tp,1,2) end
    local ct=0
    for i=1,ft do
        local token=Duel.CreateToken(tp,851632003)
        if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
            ct=ct+1
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetRange(LOCATION_MZONE)
            e1:SetAbsoluteRange(tp,1,0)
            e1:SetCondition(function(e) return e:GetHandler():IsControler(e:GetOwnerPlayer()) end)
            e1:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_DARK) end)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
            token:RegisterEffect(e1,true)
        end
    end
    Duel.SpecialSummonComplete()
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetTargetRange(1,0)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e2,tp)
end

function s.spconfilter(c)
    return c:IsFaceup() and (c:IsCode(CARD_ABYSSAL_DREDGE) or (c:ListsCode(CARD_ABYSSAL_DREDGE)))
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not (re:IsMonsterEffect() and re:GetActivateLocation()==LOCATION_MZONE) then return false end
    local g=Duel.GetMatchingGroup(s.spconfilter,tp,LOCATION_MZONE,0,nil)
    return #g==0
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.revfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_REPTILE) and not c:IsPublic()
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
        Duel.ConfirmCards(1-tp,c)
        if Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(1)
            and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
            local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil)
            if #g>0 then
                Duel.ConfirmCards(1-tp,g)
                Duel.ShuffleHand(tp)
                Duel.BreakEffect()
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        end
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetDescription(aux.Stringid(id,3))
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetCondition(function(e) return e:GetHandler():IsControler(e:GetOwnerPlayer()) end)
        e1:SetTarget(function(e,c) return not c:IsRace(RACE_REPTILE) end)
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        Duel.RegisterEffect(e1,tp)
    end
end