--Shackles from the Ceremonial Duel

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

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_IMMUNE_EFFECT)
        e8:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e8:SetTargetRange(0,LOCATION_ONFIELD)
        e8:SetTarget(s.gandfilter)
        e8:SetValue(s.efilter2)
        Duel.RegisterEffect(e8, tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_DISABLE)
        e9:SetTargetRange(LOCATION_MZONE,0)
        e9:SetCondition(s.discon)
        e9:SetTarget(function (_,c) return not c:IsCode(92110878) end)
        Duel.RegisterEffect(e9, tp)

        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_IMMUNE_EFFECT)
        e10:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e10:SetTargetRange(0,LOCATION_ONFIELD)
        e10:SetTarget(s.gandfilter2)
        e10:SetValue(s.efilter2)
        Duel.RegisterEffect(e10, tp)


	end
	e:SetLabel(1)
end

function s.goldsarcfilter(c)
    return c:IsFaceup() and c:IsCode(79791878)
end

function s.discon(e)
	return not Duel.IsExistingMatchingCard(s.goldsarcfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.gandfilter2(e,c)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
    if not g then return end
    local tg=g:GetMaxGroup(Card.GetAttack)
    return tg and tg:IsContains(c)
end



function s.gandfilter(e,c)

    return c:IsFacedown()
end


function s.efilter(e,te)
	return e:GetOwnerPlayer()==te:GetOwnerPlayer() and te:GetHandler():IsCode(79791878,05786513)
end

function s.efilter2(e,te)
	return e:GetOwnerPlayer()==te:GetOwnerPlayer() and te:GetHandler():IsCode(02333466)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
