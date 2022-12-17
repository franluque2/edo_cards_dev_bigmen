--Labor Pain (CT)
local s,id,alias=GetID()
function s.initial_effect(c)
    alias = c:GetOriginalCodeRule()

	c:EnableCounterPermit(0xb)

    c:SetUniqueOnField(1,0,alias)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_HAND)
	e2:SetTarget(s.sumtg)
	e2:SetCost(s.ccost)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_RELEASE)
	e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.addccon)
	e3:SetOperation(s.addc)
	c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.damtg2)
	e4:SetOperation(s.damop2)
	c:RegisterEffect(e4)

    --Set itself during the End Phase
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_COST) and re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsRace(RACE_INSECT) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(s.settg)
		e1:SetOperation(s.setop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end


function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.dreadscythefilter(c)
    return c:IsCode(66973070) and c:IsMonster() and c:IsFaceup()
end

function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0xb)
	if c:RemoveCounter(tp,0xb,ct,REASON_EFFECT) then
		if Duel.IsExistingMatchingCard(s.dreadscythefilter, tp, LOCATION_MZONE, 0, 1, nil) then
            local tc=Duel.SelectMatchingCard(tp, s.dreadscythefilter, tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
            if tc then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(ct*500)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        end
	end
end


function s.tributfilter(c,tp)
    return c:IsRace(RACE_INSECT) and c:IsPreviousControler(tp)
end

function s.addccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tributfilter,1,nil,tp)
end

function s.addc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xb,1)
end

function s.sumtg(e,c)
	return c:IsMonster()
end
function s.ccost(e,c,tp)
	return Duel.CheckLPCost(tp,500)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,500)
end