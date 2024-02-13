--Aphenphosmphobia
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
        
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e2:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetTarget(function(_,c) return c:IsMonster() end)
        e2:SetCondition(function(_) return Duel.GetTurnCount()>1 end)
        e2:SetValue(1)
        Duel.RegisterEffect(e2,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetCategory(CATEGORY_DESTROY)
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_DAMAGE_STEP_END)
        e3:SetCondition(s.descon)
        e3:SetOperation(s.desop)
        Duel.RegisterEffect(e3,tp)

	end
	e:SetLabel(1)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=Duel.GetAttacker()
	local dt=Duel.GetAttackTarget()
    if ec:GetControler()~=tp and dt then ec=dt end
	return ec and ec:IsRelateToBattle()
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ec=Duel.GetAttacker()
	local dt=Duel.GetAttackTarget()
    if ec:GetControler()~=tp and dt then ec=dt end
	if ec:IsRelateToBattle() then
        Duel.Hint(HINT_CARD,tp,id)
		Duel.Destroy(ec,REASON_RULE)
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
