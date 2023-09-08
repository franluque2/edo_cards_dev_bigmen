--Will of the Original Dimension
local s,id=GetID()

function c81632901.initial_effect(c)

		--Activate
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

function s.value(e)
	return 0x1f<<16*e:GetHandlerPlayer()
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)
	end
	e:SetLabel(1)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.znval(e)
	return ~(0x60)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.IsDuelType(0x2000) then
	--link zones
		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_BECOME_LINKED_ZONE)
		e6:SetRange(LOCATION_FZONE)
		e6:SetValue(s.value)
		Duel.RegisterEffect(e6,tp)

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_FORCE_MZONE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetTargetRange(1,0)
		e3:SetValue(s.znval)
		Duel.RegisterEffect(e3,tp)

		local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_DISABLE)
        e7:SetTargetRange(LOCATION_ONFIELD,0)
        e7:SetCondition(s.discon)
        e7:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xff))
        Duel.RegisterEffect(e7, tp)
	end
end

function s.discon(e)
	return Duel.IsBattlePhase() and Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end