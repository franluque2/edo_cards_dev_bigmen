--Ally of Justice Kingslayer
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 DARK Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),1,1,Synchro.NonTuner(nil),1,99)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE)
    e3:SetCode(EVENT_BATTLE_START)
    e3:SetCondition(s.bancon)
    e3:SetOperation(s.banop)
    c:RegisterEffect(e3)
end

function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end

function s.efilter(e,te)
    local c=te:GetHandler()
    return (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsRace(RACE_REPTILE)) and te:IsActiveType(TYPE_MONSTER)
end


function s.bancon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsControler(1-tp)
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if c:IsRelateToBattle() and bc:IsRelateToBattle() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(c:GetBaseAttack())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_SET_ATTACK_FINAL)
        e2:SetValue(bc:GetBaseAttack())
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        bc:RegisterEffect(e2)
        local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
        if #g1>0 then
            Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
        end
    end
end