--Robin, Galactic Superstar
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)

    Link.AddProcedure(c,s.matfilter,2,2)

    -- Cannot attack or be attacked while you control another link monster
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    --When a monster you control battles: give all monsters you control 500 ATK, except this card until the end phase
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_BATTLED)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.atkcon2)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
    local atk=Duel.GetAttacker()
    local bc=Duel.GetAttackTarget()
    return atk:IsControler(tp) or (bc and bc:IsControler(tp))
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_MONSTER),tp,LOCATION_MZONE,0,c)
    for tc in aux.Next(g) do
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
    end
end

function s.atkcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_LINK),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.matfilter(c,lc,st,tp)
	return c:IsType(TYPE_EFFECT,lc,st,tp) and not c:IsType(TYPE_LINK,lc,st,tp)
end