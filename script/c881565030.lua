--Phainon, Golden Heir to Worldbearing
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --you can only control 1 "Phainon, Golden Heir to Worldbearing"
	c:SetUniqueOnField(1,0,id)
	c:EnableCounterPermit(COUNTER_COREFLAME)

    --This card is also always treated as a Warrior monster.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_ALL)
    e1:SetCode(EFFECT_ADD_RACE)
    e1:SetValue(RACE_WARRIOR)
    c:RegisterEffect(e1)

    	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)


    --Once per Chain, during the Main Phase (Quick Effect), if this card has 12 coreflame counters on it: You can send any other monsters you control to the GY (if any); transform this card into "Khaslana, Golden Heir to Destruction".
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
    e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e4:SetCondition(function () return Duel.IsMainPhase() end)
    e4:SetCost(s.transfcost)
    e4:SetOperation(s.transfop)
    c:RegisterEffect(e4)


end
s.listed_names={id+1} --Khaslana, Golden Heir to Destruction
s.counter_list={COUNTER_COREFLAME}

function s.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and e:GetHandler():GetFlagEffect(1)>0 then
        local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
        if g and g:IsContains(e:GetHandler()) and e:GetHandler():GetCounter(COUNTER_COREFLAME)<12 then
		    e:GetHandler():AddCounter(COUNTER_COREFLAME,1)
        end
	end
end

function s.transfcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetCounter(COUNTER_COREFLAME)==12 end
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,e:GetHandler())
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end

function s.transfop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        Card.Recreate(c, id+1, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
        e:GetHandler():AddCounter(COUNTER_COREFLAME,12)

    end
end