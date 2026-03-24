--Khaslana, Golden Heir to Destruction
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    	c:EnableCounterPermit(COUNTER_COREFLAME)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)

    --Your other Main Monster Zones cannot be used. 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_USE_EXTRA_MZONE)
	e2:SetValue(4)
	c:RegisterEffect(e2)

    	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)

    -- Can attack twice during each battle phase. 
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_EXTRA_ATTACK)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    
    --Once per Chain, if a monster(s) is destroyed: You can destroy all monsters your opponent controls.
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
    e5:SetCondition(function (_,tp,eg) return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER) end)
    e5:SetTarget(s.destg)
    e5:SetOperation(s.desop)
    c:RegisterEffect(e5)


    --Each time a Phase Ends, remove a Coreflame Counter from this card, then if this card has no Coreflame Counters on it, transform it into "Phainon, Golden Heir to Worldbearing".
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_PHASE+PHASE_DRAW)
    e6:SetCountLimit(1)
    e6:SetRange(LOCATION_MZONE)
    e6:SetOperation(s.phaseop)
    c:RegisterEffect(e6)

    local phases={PHASE_STANDBY,PHASE_MAIN1,PHASE_BATTLE_START,PHASE_MAIN2,PHASE_END}

    for _,phase in ipairs(phases) do
        local newE=e6:Clone()
        newE:SetCode(EVENT_PHASE+phase)
        c:RegisterEffect(newE)
    end
end
s.listed_names={id-1} --Phainon, Golden Heir to Worldbearing
s.counter_list={COUNTER_COREFLAME}

function s.immval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end

function s.desfilter(c)
    return c:IsDestructable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
    Duel.Destroy(g,REASON_EFFECT)
end

function s.phaseop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetCounter(COUNTER_COREFLAME)>0 then
        c:RemoveCounter(tp,COUNTER_COREFLAME,1,REASON_EFFECT)
    else
        Card.Recreate(c, id-1, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
        Duel.AdjustInstantly(c)
    end
end