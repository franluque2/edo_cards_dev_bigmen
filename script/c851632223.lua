--Metalion ρ​​
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Choose effect based on turn count
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end
s.listed_names={CARD_BOSS_RUSH}
s.listed_series={SET_POWERUP}
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local turn=Duel.GetTurnCount()
    if turn==1 then
        --Battle Phase can be conducted
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetDescription(aux.Stringid(id, 0))
        e1:SetCode(EFFECT_BP_FIRST_TURN)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetTargetRange(1,1)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
        --All battle damage becomes 0
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e2:SetTargetRange(1,1)
        e2:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e2,tp)
        --Restriction on activations
        local op=e:GetHandler():GetOwner()
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_CANNOT_ACTIVATE)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetTargetRange(1,0)
        e3:SetValue(s.aclimit)
        e3:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e3,op)
    else
        --Place counters on non-Level 4 monsters
        local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:GetLevel()~=4 end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
        for tc in g:Iter() do
            tc:EnableCounterPermit(0x1f,LOCATION_MZONE)
            tc:AddCounter(0x1f,1)
        end
        --End of damage step effect
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetCode(EVENT_DAMAGE_STEP_END)
        e4:SetOperation(s.dsop)
        e4:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e4,tp)
    end
end

function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    return not (rc:IsSetCard(SET_POWERUP) or (rc:IsType(TYPE_SPELL+TYPE_TRAP) and (re:GetHandler():IsCode(CARD_BOSS_RUSH) or re:GetHandler():ListsCode(CARD_BOSS_RUSH))) or (rc:IsAttribute(ATTRIBUTE_LIGHT) and rc:IsRace(RACE_MACHINE)))
end

function s.dsop(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttackTarget()
    if not at then return end
    if at:GetLevel()==4 then return end
    if at:IsRelateToBattle() then
        if at:RemoveCounter(tp,0x1f,1,REASON_EFFECT)==0 then
            Duel.Destroy(at,REASON_EFFECT)
        end
    end
end