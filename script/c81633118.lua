--Shackles of an Unrequited Love
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
        e3:SetTargetRange(LOCATION_ONFIELD,0)
        e3:SetTarget(s.distg)
		Duel.RegisterEffect(e3,tp)

		local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(function (_, c) return c:GetBaseAttack()>0 end)
	e4:SetValue(500)
	Duel.RegisterEffect(e4,tp)

       
	end
	e:SetLabel(1)
end


function s.distg(e,c)
    local bc=Duel.GetAttacker()
    local ph=Duel.GetCurrentPhase()

	if bc and c:IsCode(65261141) and (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then
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
