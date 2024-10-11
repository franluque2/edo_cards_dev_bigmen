--Unmaking Combustion
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Flip face-up
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
    e2:SetCondition(s.upcon)
    e2:SetOperation(s.upop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_NO_LP_GAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,0)
	c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(s.reptg)
	c:RegisterEffect(e5)

end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		and Duel.CheckLPCost(tp,math.floor(Duel.GetLP(tp)/2)) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
		return true
	else return false end
end

function s.sumfilter(c,tp)
    return c:IsFaceup() and c:IsSummonPlayer(tp) and c:CanAttack()
end

function s.upcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sumfilter,1,nil,1-tp) and #eg==1
end
function s.upop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    if tc:IsOnField() and s.sumfilter(tc,1-tp) then

        Duel.CalculateDamage(tc, nil)

        local dam=Duel.GetBattleDamage(tp)
        
        Duel.Damage(1-tp,dam,REASON_EFFECT)

    end
end
