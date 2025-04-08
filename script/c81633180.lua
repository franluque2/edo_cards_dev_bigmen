--Ray's Nautral Energy
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

    aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)

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

function s.negatablemon(c)
    return c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.negatablemon, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
        
	Duel.Hint(HINT_CARD,tp,id)
    local g=Duel.GetMatchingGroup(s.negatablemon, tp, LOCATION_ONFIELD, LOCATION_MZONE, nil)
	local c=e:GetHandler()
	local tc=g:Select(tp, 1,1,nil):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
        e1:SetCode(EFFECT_REMOVE_TYPE)
        e1:SetValue(TYPE_PENDULUM)
        tc:RegisterEffect(e1)

        local e2=e1:Clone()
        e2:SetCode(EFFECT_CANNOT_TO_DECK)
        e2:SetCondition(function(_e) return _e:GetHandler():GetDestination()==LOCATION_GRAVE end)
        e2:SetValue(1)
        tc:RegisterEffect(e2)

        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetRange(LOCATION_SZONE)
        e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_UNCOPYABLE)
        e3:SetTargetRange(1,0)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_MSCHANGE)
        e3:SetTarget(s.psplimit)
        tc:RegisterEffect(e3)
    
        if Duel.IsDuelType(DUEL_SEPARATE_PZONE) then
            Duel.BreakEffect()
            Duel.SendtoGrave(tc, REASON_RULE)
            return
        end
        Duel.MoveToField(tc, tp, tc:GetControler(), LOCATION_SZONE, POS_FACEUP, true, tc:GetSequence())
		tc:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))

	end

	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    
end

function s.psplimit(e,c,tp,sumtp,sumpos)
	return (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end