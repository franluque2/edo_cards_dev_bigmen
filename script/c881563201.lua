--Ten Stonehearts - Topaz of Debt Retrieval
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()

    c:EnableCounterPermit(COUNTER_DEBTOR)

    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_IPC),2,99)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_BATTLED)
    e1:SetCondition(s.racon)
    e1:SetOperation(s.raop)
    c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_BATTLED)
    e2:SetCondition(s.racon2)
    e2:SetOperation(s.raop2)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.sumcon)
    e3:SetOperation(s.sumop)
    e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
    c:RegisterEffect(e3)

    local e4=e3:Clone()
    e4:SetCode(EVENT_CUSTOM+id)
    c:RegisterEffect(e4)


end
s.listed_names={TOKEN_FOLLOWUP}
s.counter_place_list={COUNTER_DEBTOR}

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return WbAux.CanPlayerSpecialSummonFollowupToken(tp)
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
    e:GetHandler():RemoveCounter(tp,COUNTER_DEBTOR,3,REASON_EFFECT)
end

function s.racon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker()~=e:GetHandler()
end
function s.raop2(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():GetCounter(COUNTER_DEBTOR)>=3 then return end
    e:GetHandler():AddCounter(COUNTER_DEBTOR,1)

    if e:GetHandler():GetCounter(COUNTER_DEBTOR)==3 then
        Duel.RaiseSingleEvent(e:GetHandler(), EVENT_CUSTOM+id, e:GetHandler(), 0, tp, tp, 0)
    end
end


function s.racon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget() and Duel.GetAttacker():IsControler(tp) and Duel:GetAttacker():IsType(TYPE_TOKEN)
end
function s.raop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
    local atk=Duel.GetAttacker()
	if (not d) or d:IsFacedown() then return end
    local atkval=atk:GetAttack()
    local defval=atk:GetDefense()

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-atkval)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    d:RegisterEffect(e1)

    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(-defval)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    d:RegisterEffect(e2)
end
