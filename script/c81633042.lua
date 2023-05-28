--Golden Shackles of Fiction
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
        e7:SetCode(EFFECT_CANNOT_ACTIVATE)
        e7:SetTargetRange(LOCATION_ALL,0)
        e7:SetCondition(s.discon)
        e7:SetTarget(s.actfilter)
        Duel.RegisterEffect(e7, tp)

        local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCondition(s.discon)
	e3:SetTargetRange(LOCATION_ALL,0)
	e3:SetTarget(s.actfilter)
    Duel.RegisterEffect(e3, tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_DISABLE)
        e8:SetTargetRange(LOCATION_MZONE,0)
		e8:SetCondition(function (ef) return Duel.GetTurnPlayer()~=ef:GetHandlerPlayer() end)
        e8:SetTarget(function (_,c) return c:IsOriginalCode(74889525) end)
        Duel.RegisterEffect(e8, tp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(s.repcon)
		e2:SetOperation(s.repop)
		Duel.RegisterEffect(e2,tp)

		local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_CHANGE_CODE)
        e4:SetTargetRange(LOCATION_MZONE,0)
		e4:SetCondition(function (ef) return Duel.GetTurnPlayer()~=ef:GetHandlerPlayer() end)
        e4:SetTarget(function (_,c) return c:IsOriginalCode(74889525) end)
        e4:SetValue(CARD_GOLDEN_LORD)
        Duel.RegisterEffect(e4,tp)

	end
	e:SetLabel(1)
end

function s.validremovefilter(c, e)
    return c:GetCardEffect()~=nil
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.validremovefilter, 1, nil, e) and re:GetHandler():IsOriginalCode(CARD_GOLDEN_LORD)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=eg:GetFirst()

    while tc do
        if s.validremovefilter(tc, e) then
			tc:ResetEffect(EFFECT_INDESTRUCTABLE_EFFECT,RESET_CODE)
        end
        tc=eg:GetNext()
    end

end

function s.discon(e)
	return not (Duel.IsBattlePhase() or (Duel.GetCurrentPhase()==PHASE_END))
end

function s.actfilter(e,c)
	return c:IsSetCard(0x144) and c:IsTrap()
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
