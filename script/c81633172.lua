--The Numeron Code
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


        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
        e2:SetTargetRange(LOCATION_HAND,0)
        e2:SetCondition(s.nocardcon)
        Duel.RegisterEffect(e2,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
        e3:SetTargetRange(LOCATION_HAND,0)
        e3:SetCondition(s.nocardcon)
        Duel.RegisterEffect(e3,tp)


	end
	e:SetLabel(1)
end

function s.nocardcon(e,c)
	return	Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
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
