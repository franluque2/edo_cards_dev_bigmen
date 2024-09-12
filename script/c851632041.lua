--Flamvell Endless Flame
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.gaincon)
	e2:SetTarget(s.gaintg)
	e2:SetOperation(s.gainop)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_CONJURE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
    e3:SetCondition(aux.exccon)
	e3:SetTarget(s.sptar)
	e3:SetOperation(s.activate2)
	e3:SetCountLimit(1,{id,2})
	c:RegisterEffect(e3)
end
s.listed_series={SET_FLAMVELL}

function s.gaincon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep==1-tp and tc:IsControler(tp) and Duel.GetAttackTarget() and tc:IsAttribute(ATTRIBUTE_FIRE)
end

function s.gaintg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.gainop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    if not (tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()) then return end
    local num=Duel.GetBattleDamage(1-tp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(num)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)

    local e3=e1:Clone()
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(1)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e3)
end

function s.spfil(c,e,tp)
    return c:IsSetCard(SET_FLAMVELL) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP)
end

function s.sptar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp, LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfil), tp, LOCATION_GRAVE, 0, 1,nil,e,tp)
     end
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tosum=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.spfil), tp, LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
    if tosum and Duel.SpecialSummon(tosum, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP) then
        Duel.BreakEffect()
        local poun=Duel.CreateToken(tp,28332833)
        Duel.SpecialSummon(poun, SUMMON_TYPE_SPECIAL, tp, 1-tp, false, false, POS_FACEDOWN_DEFENSE)
    
    end
end