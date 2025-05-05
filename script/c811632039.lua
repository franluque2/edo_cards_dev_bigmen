--No Time to Die
Duel.LoadScript("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    aux.AddSkillProcedure(c,2,false,nil,nil)


    local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)


end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)


        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_MSET)
		e2:SetOperation(s.setstatuschange)
		Duel.RegisterEffect(e2,tp)


        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e3:SetTargetRange(LOCATION_SZONE,0)
        e3:SetTarget(aux.TargetBoolFunction(s.cardfilter))
        Duel.RegisterEffect(e3,tp)

        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetCode(EVENT_FREE_CHAIN)
        e4:SetCondition(s.flipcon2)
        e4:SetOperation(s.flipop2)
        Duel.RegisterEffect(e4,tp)
    end
	e:SetLabel(1)
end

function s.cardfilter(c)
	return c:IsContinuousTrap() and c:IsTrapMonster()
end

function s.setstatuschange(e,tp,eg,ev,ep,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.GetTurnPlayer()==tp then
		tc:SetStatus(STATUS_SUMMON_TURN, false)
	end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end

function s.sumfilter(c)
	return c:IsSummonable(true,nil,1)
end

function s.sumfilter2(c)
	return Card.IsDiscardable(c,REASON_COST) and Duel.IsExistingMatchingCard(s.sumfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.sumfilter2,tp,LOCATION_HAND,0,1,nil)
end

function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,tp,id)
    Duel.DiscardHand(tp,s.sumfilter2,1,1,REASON_COST|REASON_DISCARD)
    local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil,1)
	end
end
