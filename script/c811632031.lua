--Arcane Coils
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

        local c=e:GetHandler()

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_DRAW)
		e1:SetCondition(s.flipcon)
        e1:SetCountLimit(1)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e2:SetCode(EFFECT_BECOME_QUICK)
        e2:SetTargetRange(0x3f,0)
        e2:SetTarget(aux.TargetBoolFunction(Card.IsSpell))
        Duel.RegisterEffect(e2,tp)


        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
        e3:SetTargetRange(LOCATION_HAND,0)
        e3:SetTarget(aux.TargetBoolFunction(Card.IsSpell))
        Duel.RegisterEffect(e3,tp)



	e:SetLabel(1)
    end
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


end
