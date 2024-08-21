--Chrono Shackles of Fiction
Duel.LoadScript("big_aux.lua")

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

local REGULATOR=19891131
local REDOER=55285840

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_DISABLE)
        e8:SetTargetRange(LOCATION_MZONE,0)
        e8:SetTarget(function (_,c) return c:GetFlagEffect(id+100)>0 and not c:IsOriginalCode(REGULATOR) end)
        Duel.RegisterEffect(e8, tp)

        local e19=Effect.CreateEffect(e:GetHandler())
        e19:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
        e19:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e19:SetCode(EVENT_SPSUMMON_SUCCESS)
        e19:SetOperation(s.regulatorcheck)
        Duel.RegisterEffect(e19,tp)

        local e18=Effect.CreateEffect(e:GetHandler())
        e18:SetType(EFFECT_TYPE_FIELD)
        e18:SetCode(EFFECT_CANNOT_TRIGGER)
        e18:SetTargetRange(LOCATION_MZONE,0)
        e18:SetCondition(s.discon1)
        e18:SetTarget(s.actfilter1)
        Duel.RegisterEffect(e18, tp)

        local e20=e18:Clone()
        e20:SetCondition(s.discon2)
        e20:SetTarget(s.actfilter2)
        Duel.RegisterEffect(e20, tp)

        local e21=Effect.CreateEffect(e:GetHandler())
        e21:SetType(EFFECT_TYPE_FIELD)
        e21:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e21:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e21:SetTargetRange(LOCATION_MZONE,0)
        e21:SetTarget(s.actfilter2)
        e21:SetValue(s.value)
        Duel.RegisterEffect(e21, tp)


	end
	e:SetLabel(1)
end

function s.value(e,re,rp)
	return re:GetHandlerPlayer()==e:GetHandlerPlayer()
end

function s.discon2(e)
	return Duel.GetCurrentPhase()==PHASE_STANDBY
end

function s.actfilter2(e,c)
	if not c:IsCode(REDOER) then return false end
    return c:IsFaceup() and (#c:GetOverlayGroup()>=3)
end

function s.discon1(e)
	return Duel.IsBattlePhase() or ((Duel.GetTurnPlayer()==e:GetHandlerPlayer()) and Duel.GetCurrentPhase()==PHASE_STANDBY)
end

function s.actfilter1(e,c)
	return c:IsCode(REDOER)
end

function s.regulatorcheck(e,tp,eg,ev,ep,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	if (rc:IsCode(REGULATOR)) then
		local ec=eg:GetFirst()
		while ec do
			ec:RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD,0,0)
			ec=eg:GetNext()
		end
	end
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

