--Shackles of the Black Flame
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
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
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here  
        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetTargetRange(0,LOCATION_MZONE)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)

        
        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_CHAINING)
		e5:SetCondition(s.discon)
		e5:SetOperation(s.disop)
		Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_CANNOT_TRIGGER)
        e6:SetTargetRange(LOCATION_MZONE,0)
        e6:SetCondition(s.discon2)
        e6:SetTarget(s.actfilter)
        Duel.RegisterEffect(e6, tp)

	end
	e:SetLabel(1)
end


function s.discon2(e)
	return Duel.GetFlagEffect(tp,id+1)>0
end

function s.actfilter(e,c)
	return c:IsCode(48229808)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()

	return re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(48229808) and (Duel.GetFlagEffect(tp,id+1)==0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.efilter(e,te)
	return te:GetHandler():IsSetCard(SET_HORUS)
end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
