--Shackes of Hatred
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

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_ADD_RACE)
        e3:SetTargetRange(0,LOCATION_MZONE)
        e3:SetCondition(s.changecon)
        e3:SetValue(RACE_DRAGON)
        Duel.RegisterEffect(e3,tp)
        
	end
	e:SetLabel(1)
end
function s.efilter(e,te)
	return e:GetOwnerPlayer()==te:GetOwnerPlayer() and te:GetHandler():IsCode(11790356,86240887)
end

function s.bdragonfilter(c)
    return c:IsCode(11790356) and c:IsFaceup() and not c:IsDisabled()
end

function s.changecon(e)
    return Duel.IsExistingMatchingCard(s.bdragonfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end