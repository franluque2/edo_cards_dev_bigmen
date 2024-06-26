--Shackles of the Black Flame
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

	aux.GlobalCheck(s,function()
		s.name_list={}
		s.name_list[0]={}
		s.name_list[1]={}
		aux.AddValuesReset(function()
			s.name_list[0]={}
			s.name_list[1]={}
		end)
	end)
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
		e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
        e7:SetTargetRange(0,LOCATION_MZONE)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)

        
        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_CHAINING)
		e5:SetCondition(s.discon)
		e5:SetOperation(s.disop)
		Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e6:SetCode(EFFECT_CANNOT_TRIGGER)
        e6:SetTargetRange(LOCATION_ALL,0)
        e6:SetCondition(s.discon2)
        e6:SetTarget(s.actfilter)
        Duel.RegisterEffect(e6, tp)

		--negate sarcophagus

		local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_DISABLE)
        e8:SetTargetRange(LOCATION_ONFIELD,0)
		e8:SetCondition(s.discon3)
        e8:SetTarget(aux.TargetBoolFunction(Card.IsOriginalCode,CARD_KING_SARCOPHAGUS))
        Duel.RegisterEffect(e8, tp)

		--cannot activate cards when a card is destroyed

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DESTROY)
		e3:SetCondition(s.limcon)
		e3:SetOperation(s.limop)
        Duel.RegisterEffect(e3, tp)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_CHAIN_END)
		e4:SetOperation(s.limop2)
        Duel.RegisterEffect(e4, tp)

		-- sp summon the little horuses

		local e11=Effect.CreateEffect(e:GetHandler())
		e11:SetDescription(aux.Stringid(84941194,0))
		e11:SetType(EFFECT_TYPE_FIELD)
		e11:SetCode(EFFECT_SPSUMMON_PROC)
		e11:SetRange(LOCATION_GRAVE)
		e11:SetCountLimit(1)
		e11:SetCondition(s.spcon)

		local e12=Effect.CreateEffect(e:GetHandler())
		e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e12:SetTargetRange(LOCATION_GRAVE,0)
		e12:SetTarget(function(e,c) return c:IsCode(11224103,75830094) end)
		e12:SetLabelObject(e11)
		Duel.RegisterEffect(e12,tp)

		local e22=Effect.CreateEffect(e:GetHandler())
		e22:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e22:SetCode(EVENT_SPSUMMON_SUCCESS)
		e22:SetCondition(s.repcon)
		e22:SetOperation(s.repop)
		Duel.RegisterEffect(e22,tp)
	end
	e:SetLabel(1)
end

function s.littlehorusfilter(c)
	return c:IsCode(11224103,75830094) and c:GetPreviousLocation()==LOCATION_GRAVE and not (c:GetReasonEffect():IsActiveType(EFFECT_TYPE_ACTIVATE))
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.littlehorusfilter, 1, nil)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	if not rp==tp then return end
	local g=Group.Filter(eg, s.littlehorusfilter, nil)
	for c in g:Iter() do
		s.name_list[e:GetHandlerPlayer()][c:GetCode()]=true
	end
end


function s.spcon(e,c)
	if c==nil then return true end
	if s.name_list[e:GetHandlerPlayer()][c:GetCode()]==true then return false end
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_KING_SARCOPHAGUS),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.limfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsSpell()
end
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)>0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end

function s.chainlm(e,rp,tp)
	return tp~=rp
end


function s.discon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() or (Duel.GetTurnPlayer()~=e:GetHandlerPlayer())
end


function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+1)>0
end

function s.actfilter(e,c)
	return c:IsCode(48229808)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()

	return re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(48229808) and (Duel.GetFlagEffect(tp,id+1)==0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,0)
end


function s.efilter(e,te)
	return te:GetHandler():IsSetCard(SET_HORUS)
end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
