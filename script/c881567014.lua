--Protoss Void Ray
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indestg)
	e2:SetValue(1)
	c:RegisterEffect(e2)

    --Can attack all monsters your opponent controls, twice each.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_ATTACK_ALL)
    e3:SetValue(2)
    c:RegisterEffect(e3)

    --You take no Battle Damage from battles involving this Linked card.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetCondition(function(e) return e:GetHandler():IsLinked() end)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    --Gains 1000 ATK/DEF x the number of Attacks this card has declared this battle phase.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_UPDATE_ATTACK)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetValue(function(e) return e:GetHandler():GetAttackedCount()*1000 end)
    c:RegisterEffect(e5)

    local e6=e5:Clone()
    e6:SetCode(EFFECT_UPDATE_DEFENSE)
    e6:SetValue(function(e) return e:GetHandler():GetAttackedCount()*1000 end)
    c:RegisterEffect(e6)
end
s.listed_series={SET_PROTOSS}

function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsTurnPlayer(c:GetControler()) and Duel.GetTurnCount()%2==0
end

function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end