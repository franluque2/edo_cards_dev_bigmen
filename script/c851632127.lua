--Alien Spawn
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.adcon)
	e2:SetTarget(s.adtg)
	e2:SetValue(s.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
s.listed_series={0xc}
s.counter_list={COUNTER_A}

function s.adcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
function s.adtg(e,c)
	local bc=c:GetBattleTarget()
	return bc and c:GetCounter(COUNTER_A)~=0 and bc:IsSetCard(0xc)
end
function s.adval(e,c)
	return c:GetCounter(COUNTER_A)*-300
end