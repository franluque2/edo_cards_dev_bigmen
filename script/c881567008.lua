--Protoss Sentry
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --If you have more cards in hand than your opponent does, you can Special Summon this card (from your hand). You can only Special Summon "Protoss Sentry" once per turn this way.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    --During the Main Phase, if this card is Linked (Quick Effect): You can make all monsters your opponent currently controls unaffected by your opponent's card effects for the rest of this turn. 
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(_e) return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.immconfilter,_e:GetHandler():GetControler(),LOCATION_ONFIELD,LOCATION_MZONE,1,c,c,c:GetLinkedGroup()) end)
    e2:SetTarget(s.immtar)
    e2:SetOperation(s.op)
    c:RegisterEffect(e2)
end

function s.spcon(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
        and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)>Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_HAND)
end

function s.immtar(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    for tc in g:Iter() do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetValue(s.efilter)
        tc:RegisterEffect(e1)
    end
end

function s.efilter(e,re)
    return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

function s.immconfilter(c,ec,lg)
	return c:IsFaceup() and (lg:IsContains(c) or c:GetLinkedGroup():IsContains(ec))
end