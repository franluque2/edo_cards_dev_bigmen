--Makers' Portal
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

        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
        e11:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e11:SetTargetRange(0,1)
        e11:SetValue(s.damval)
        Duel.RegisterEffect(e11,tp)

	end
	e:SetLabel(1)
end


function s.linkedarrowfilter(c,tc)
    return c:IsFaceup() and c:IsCode(511009503) and c:GetLinkedGroup():IsContains(tc)
end

function s.isanarrowcontaining(c,tp)
    return Duel.IsExistingMatchingCard(s.linkedarrowfilter, tp, LOCATION_SZONE, 0, 1, nil,c)
end

function s.damval(e,rc)
	if not ((rc:GetLinkedGroup():FilterCount(Card.IsCode,nil,511009503)>0) or s.isanarrowcontaining(rc,e:GetHandlerPlayer())) then return -1 end
	return HALF_DAMAGE
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



function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

	return aux.CanActivateSkill(tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
	Duel.Hint(HINT_CARD,tp,id)

    local arrows=Duel.CreateToken(tp, 511009503)
    Duel.MoveToField(arrows,tp,tp,LOCATION_SZONE,POS_FACEUP,true)


	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    end
end
