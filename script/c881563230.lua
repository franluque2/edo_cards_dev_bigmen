--General Feixiao
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()

    c:EnableCounterPermit(COUNTER_FLYING_AUREUS)

    Link.AddProcedure(c,aux.FilterBoolFunctionEx(s.mfilter),2)

    --You take no battle damage from battles involving your tokens.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(function(e,tp) return tp==e:GetHandlerPlayer() end)
    e1:SetValue(function(e,re,r,rp) return e:GetHandlerPlayer()==rp and re:IsActiveType(TYPE_TOKEN) end)
    c:RegisterEffect(e1)



    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_BATTLED)
    e2:SetCondition(s.racon2)
    e2:SetOperation(s.raop2)
    c:RegisterEffect(e2)


    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_CUSTOM+id)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.battlecon2)
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

    --Once per Chain (Quick Effect): You can remove 6 Flying Aureus Counters from this card, then target 1 face-up card your opponent controls; banish it, face-down.
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
    e4:SetCost(function(_,tp) return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_FLYING_AUREUS,6,REASON_COST) end)
    e4:SetTarget(s.bantarg)
    e4:SetOperation(s.banop)
    c:RegisterEffect(e4)
end
s.listed_names={TOKEN_FOLLOWUP}
s.counter_place_list={COUNTER_FLYING_AUREUS}

function s.mfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_IPC,lc,sumtype,tp) or c:IsType(TYPE_TOKEN,lc,sumtype,tp)
end

function s.fuatokenbattlefilter(c)
    return c:IsCode(TOKEN_FOLLOWUP) and c:IsFaceup() and c:GetFlagEffect(id)==0
end

function s.racon2(e,tp,eg,ep,ev,re,r,rp)
    local a1=Duel.GetAttacker()
    local a2=Duel.GetAttackTarget()
    local g=Group.FromCards(a1,a2)
	return g:IsExists(s.fuatokenbattlefilter, 1, nil)
end
function s.raop2(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():GetCounter(COUNTER_FLYING_AUREUS)>=12 then return end
    e:GetHandler():AddCounter(COUNTER_FLYING_AUREUS,1)

    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)

end

function s.battlecon2(e,tp,eg,ep,ev,re,r,rp)
	return WbAux.CanPlayerSpecialSummonFollowupToken(tp)
end


function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local token=WbAux.GetFollowupToken(tp,e:GetHandler())
    if token then
        token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
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
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	Duel.RaiseSingleEvent(e:GetHandler(), EVENT_CUSTOM+id, 0, REASON_EFFECT, e:GetHandlerPlayer(), e:GetHandlerPlayer(), 0)
end

function s.bantarg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
    e:SetLabelObject(g:GetFirst())
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
    end
end