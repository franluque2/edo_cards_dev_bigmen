--Shackles of the 3rd Card Professor
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

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_DISABLE)
        e3:SetTargetRange(LOCATION_MZONE,0)
        e3:SetTarget(s.distg)
		Duel.RegisterEffect(e3,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_DISABLE)
        e8:SetTargetRange(LOCATION_ONFIELD,0)
        e8:SetTarget(aux.TargetBoolFunction(Card.IsCode,27134209))
        Duel.RegisterEffect(e8, tp)


        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_CHAINING)
		e5:SetCondition(s.discon)
		e5:SetOperation(s.disop)
		Duel.RegisterEffect(e5,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_CANNOT_TRIGGER)
        e7:SetTargetRange(LOCATION_MZONE,0)
        e7:SetCondition(s.discon2)
        e7:SetTarget(s.actfilter)
        Duel.RegisterEffect(e7, tp)

        local e10=Effect.CreateEffect(e:GetHandler())
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e10:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e10:SetTarget(s.rmtarget)
	e10:SetTargetRange(LOCATION_MZONE,0)
	e10:SetValue(LOCATION_REMOVED)
    Duel.RegisterEffect(e10,tp)

    local e9=Effect.CreateEffect(e:GetHandler())
    e9:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e9:SetCode(EVENT_SPSUMMON_SUCCESS)
    e9:SetOperation(s.spsumcheck)
    Duel.RegisterEffect(e9,tp)

	end
	e:SetLabel(1)
end

function s.spsumcheck(e,tp,eg,ev,ep,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	if (rc:IsCode(27134209,50855622)) then
		local ec=eg:GetFirst()
		while ec do
			ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
			ec=eg:GetNext()
		end
	end
end

function s.rmtarget(e,c)
	if (c:GetFlagEffect(id)>0) then
		return true
	else
		return false
	end
end

function s.discon2(e)
    local ph=Duel.GetCurrentPhase()

	return  (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and Duel.GetFlagEffect(tp,id+1)>0
end

function s.actfilter(e,c)
	return c:IsCode(27134209)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()

	return re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(27134209) and (Duel.GetFlagEffect(tp,id+1)==0)
        and (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.distg(e,c)
    local bc=Duel.GetAttacker()
    local ph=Duel.GetCurrentPhase()

	if c:IsRelateToBattle() and bc and c:IsControler(e:GetHandlerPlayer())
		and bc:IsFaceup() and c:IsCode(39078434) and (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then
		return true
	end
	return false
end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
