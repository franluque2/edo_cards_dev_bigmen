--Shackles of the Underdog
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
        
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_DISABLE)
        e8:SetTargetRange(LOCATION_MZONE,0)
		e8:SetCondition(function (ef) return Duel.GetTurnPlayer()~=ef:GetHandlerPlayer() end)
        e8:SetTarget(function (_,c) return c:IsOriginalCode(00324483) end)
        Duel.RegisterEffect(e8, tp)


        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetTargetRange(0,LOCATION_ONFIELD)
        e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e7:SetCondition(function (ef) return Duel.IsExistingMatchingCard(Card.IsFacedown, 1-ef:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil) end)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)

        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_CHAINING)
		e5:SetCondition(s.discon)
		e5:SetOperation(s.disop)
        e5:SetCountLimit(1)
		Duel.RegisterEffect(e5,tp)



	end
	e:SetLabel(1)
end


function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()

	return re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(00324483)
        and (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	
end

function s.damval(e,rc)
	if not rc:IsCode(00324483) then return -1 end
	return HALF_DAMAGE
end




function s.efilter(e,te, c)
	return e:GetHandler()~=te:GetHandler() and c~=te:GetHandler() and c:IsFaceup() and te:GetHandler():IsCode(62091148,08080257)
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
