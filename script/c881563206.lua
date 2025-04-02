--Ten Stonehearts - Aventurine of Stratagems
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()

    c:EnableCounterPermit(COUNTER_BLIND_BET)

    Link.AddProcedure(c,aux.FilterBoolFunctionEx(s.mfilter),2)

    --Cannot be targetted by your opponent's card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_BATTLED)
    e2:SetOperation(s.raop2)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.sumcon)
    e3:SetOperation(s.sumop)
    e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
    c:RegisterEffect(e3)


    local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_ADJUST)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(function(e) return (e:GetHandler():GetFlagEffect(id)>0) and (Duel.GetCurrentChain()==0) and (not Duel.IsPhase(PHASE_DAMAGE)) end)
	e7:SetOperation(s.adop)
	c:RegisterEffect(e7)

    local e4=e3:Clone()
    e4:SetCode(EVENT_CUSTOM+id)
    e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.battlecon2)

    c:RegisterEffect(e4)

    --When a Token battles: Place one Guard Counter on each face-up non-token monster you control without one at the end of the damage step
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_BATTLED)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.racon)
    e5:SetOperation(s.raop)
    c:RegisterEffect(e5)

	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	c:RegisterEffect(e6)
end
s.listed_names={TOKEN_FOLLOWUP}
s.counter_place_list={COUNTER_BLIND_BET}

function s.mfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_IPC,lc,sumtype,tp) or c:IsType(TYPE_TOKEN,lc,sumtype,tp)
end


function s.battlecon2(e,tp,eg,ep,ev,re,r,rp)
	return WbAux.CanPlayerSpecialSummonFollowupToken(tp)
end


function s.adop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	Duel.RaiseSingleEvent(e:GetHandler(), EVENT_CUSTOM+id, 0, REASON_EFFECT, e:GetHandlerPlayer(), e:GetHandlerPlayer(), 0)
end

function s.racon(e,tp,eg,ep,ev,re,r,rp)
    local atk=Duel.GetAttacker()
    local defender=Duel.GetAttackTarget()

    return Duel.IsExistingMatchingCard(s.guardtokenfilter, tp, LOCATION_MZONE, 0, 1, nil) and ((atk:IsControler(tp) and atk:IsType(TYPE_TOKEN)) or (defender and defender:IsControler(tp) and defender:IsType(TYPE_TOKEN)))
end

function s.guardtokenfilter(c)
    return c:IsFaceup() and c:GetCounter(0x1021)==0 and not c:IsType(TYPE_TOKEN)
end

function s.raop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.guardtokenfilter, tp, LOCATION_MZONE, 0, nil)
    for tc in aux.Next(g) do
        if not tc:IsType(TYPE_TOKEN) then
            tc:AddCounter(0x1021,1)
            if tc:GetFlagEffect(id+500)~=0 then return end
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EFFECT_DESTROY_REPLACE)
            e1:SetTarget(s.reptg)
            e1:SetOperation(s.repop)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            tc:RegisterFlagEffect(id+500,RESET_EVENT+RESETS_STANDARD,0,0)
        end
    end
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE+REASON_RULE) and e:GetHandler():GetCounter(0x1021)>0 end
	return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp,chk)
	e:GetHandler():RemoveCounter(tp,0x1021,1,REASON_EFFECT)
end


function s.raop2(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():GetCounter(COUNTER_BLIND_BET)>=7 then return end
    e:GetHandler():AddCounter(COUNTER_BLIND_BET,1)

    if e:GetHandler():GetCounter(COUNTER_BLIND_BET)==7 then
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    end
end


function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return WbAux.CanPlayerSpecialSummonFollowupToken(tp) and (e:GetHandler():GetFlagEffect(id)==0)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local token=WbAux.GetFollowupToken(tp,e:GetHandler())
    if token then
        local g=Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
        if g and (#g>0) then
            local tc=g:RandomSelect(tp, 1):GetFirst()
            Duel.CalculateDamage(token, tc)
        else
            Duel.CalculateDamage(token, nil)
        end
    end
    if Card.IsOnField(token) then
        Duel.Destroy(token, REASON_RULE)
    end
    e:GetHandler():RemoveCounter(tp,COUNTER_BLIND_BET,7,REASON_EFFECT)
end