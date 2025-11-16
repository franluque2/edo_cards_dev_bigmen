--Powerup - Snake Option
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.condition)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return true end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --Prevent destruction
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(s.indesval)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
    --Second attack
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.atktg)
    e2:SetValue(1)
    e2:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e2,tp)
end

function s.indesval(e,c)
    return c:IsFaceup() and c:IsControler(1-e:GetHandlerPlayer())
end

function s.atktg(e,c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
end

function s.atktg2(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    if tc:IsControler(tp) and tc:IsAttribute(ATTRIBUTE_LIGHT) and tc:IsRace(RACE_MACHINE) then
        local g=Duel.GetMatchingGroup(s.atktg2,tp,LOCATION_MZONE,0,nil)
        for tcc in g:Iter() do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(200)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tcc:RegisterEffect(e1)
        end
    end
end