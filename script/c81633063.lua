--Shackles of the Fallen Commoners
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
        e7:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
        e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e9:SetCode(EVENT_SPSUMMON_SUCCESS)
        e9:SetOperation(s.mreborncheck)
        Duel.RegisterEffect(e9,tp)
    

        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
        e10:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e10:SetTarget(s.rmtarget)
        e10:SetTargetRange(LOCATION_MZONE,0)
        e10:SetValue(LOCATION_REMOVED)
        Duel.RegisterEffect(e10,tp)

	end
	e:SetLabel(1)
end

function s.mreborncheck(e,tp,eg,ev,ep,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	if (rc:IsCode(39185163) and eg:GetFirst():IsCode(39185163)) then
		local ec=eg:GetFirst()
		while ec do
            if ec:GetPreviousLocation()==LOCATION_GRAVE then
                ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
            end
			ec=eg:GetNext()
		end
	end
end

function s.rmtarget(e,c)
	if c:GetFlagEffect(id)>0 then
		return true
	else
		return false
	end
end

function s.efilter(e,te)
	return e:GetOwnerPlayer()==te:GetOwnerPlayer() and te:GetHandler():IsCode(4064256)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end