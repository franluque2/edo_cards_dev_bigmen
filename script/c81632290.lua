--Rut Trap (CT)
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end
function s.filter1(c,tp)
    return c:IsSummonPlayer(1-tp) and (c:IsLevelAbove(5) or c:IsPreviousLocation(LOCATION_EXTRA)) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.filter(c)
    return c:IsRace(RACE_BEAST) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsFaceup() and c:IsCanChangePosition()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.filter1,1,nil,tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.gyfilter(c)
    return c:IsMonster() and c:IsRace(RACE_REPTILE) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(s.filter, tp, LOCATION_MZONE, 0, nil)
    Duel.ChangePosition(g, POS_FACEUP_DEFENSE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
--Effect
    local tc=Duel.SelectTarget(tp, s.filter3, tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
    if tc then
        local c=e:GetHandler()
        local e3=Effect.CreateEffect(c)
        e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_MUST_ATTACK)
        e3:SetRange(LOCATION_MZONE)
        e3:SetTargetRange(0,LOCATION_MZONE)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e3:SetCondition(s.poscon)
        tc:RegisterEffect(e3)
        local e4=e3:Clone()
        e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
        e4:SetValue(s.atklimit)
        tc:RegisterEffect(e4)

        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetCode(EFFECT_UPDATE_DEFENSE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetValue(s.val)
        tc:RegisterEffect(e1)

    end
end
function s.filter3(c)
    return c:IsRace(RACE_BEAST) and c:IsFaceup()
end

function s.poscon(e)
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer() and Duel.IsBattlePhase()
end
function s.atklimit(e,c)
	return c==e:GetHandler()
end


function s.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsPosition, tp, LOCATION_MZONE, 0, nil, POS_DEFENSE)*500
end
