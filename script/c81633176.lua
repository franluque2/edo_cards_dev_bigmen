--The Emperor's Key
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
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
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
		e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e10:SetCode(EVENT_DAMAGE)
		e10:SetCondition(s.spcon)
		e10:SetOperation(s.spop)
		Duel.RegisterEffect(e10,tp)


        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetProperty(EFFECT_FLAG_DELAY)
        e4:SetCode(EVENT_ATTACK_DISABLED)
        e4:SetCondition(s.condition)
        e4:SetOperation(s.regop)
		Duel.RegisterEffect(e4,tp)





	end
	e:SetLabel(1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local t=Duel.GetAttackTarget()
    if not a:IsControler(tp) then a=t end
	return a and a:IsLocation(LOCATION_MZONE) and Duel.GetFlagEffect(tp, id-500)==0
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local t=Duel.GetAttackTarget()
    if not a:IsControler(tp) then a=t end

    Duel.Hint(HINT_CARD, tp, id)

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(a:GetAttackAnnouncedCount())
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    a:RegisterEffect(e1)

    Duel.RegisterFlagEffect(tp, id-500, 0, 0, 0)

end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)

	local c6=(Duel.GetFlagEffect(tp, id)==1) and Duel.GetLP(tp)<=0

	return ep==tp and c6
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)

		Duel.Hint(HINT_CARD,tp,id)
		Duel.SetLP(tp, 100)
		
        local ge1=Effect.CreateEffect(e:GetHandler())
        ge1:SetType(EFFECT_TYPE_FIELD)
        ge1:SetCode(EFFECT_CHANGE_DAMAGE)
        ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ge1:SetTargetRange(1,0)
        ge1:SetValue(0)
        ge1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(ge1,tp)
        local ge2=ge1:Clone()
        ge2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
        ge2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(ge2,tp)


        aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
