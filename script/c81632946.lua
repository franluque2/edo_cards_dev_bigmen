--In the Beginning, there was Darkness
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
	aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)
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
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetTargetRange(LOCATION_SZONE,0)
		e2:SetCondition(s.immcon)
		e2:SetTarget(s.darkness_backrow_filter)
		e2:SetValue(s.efilter)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		Duel.RegisterEffect(e3,tp)

		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e4:SetCountLimit(1)
		e4:SetCondition(s.spcon)
		e4:SetOperation(s.spop)
		Duel.RegisterEffect(e4,tp)

		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_ADD_RACE)
		e5:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
		e5:SetTarget(function (_,c) return c:IsType(TYPE_MONSTER) end)
		e5:SetValue(RACE_FIEND)
		Duel.RegisterEffect(e5,tp)

	end
	e:SetLabel(1)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(id,tp)~=0 and Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_SZONE,0,2,nil)
end

function s.getflag(g,tp)
	local flag = 0
	for c in aux.Next(g) do
		flag = flag|((1<<c:GetSequence())<<(8+(16*c:GetControler())))
	end
	if tp~=0 then
		flag=((flag<<16)&0xffff)|((flag>>16)&0xffff)
	end
	return ~flag
end

function s.filter2(c,p,otherseq)
	local seq=c:GetSequence()
	return seq<5 and c:IsControler(p) and math.abs(seq-otherseq)==1
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
		Duel.Hint(HINT_CARD,tp,id)

		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,0,nil)
		g=g:Filter(Card.IsFacedown,nil)
		local tc=g:Select(tp, 1, 1,false,nil):GetFirst()
		g=g:Filter(s.filter2, nil, tp, tc:GetSequence())
		local filter=s.getflag(g,tp)
			Duel.HintSelection(tc)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			local zone=Duel.SelectFieldZone(tp,1,LOCATION_SZONE,0,filter)
			filter=filter|zone
			local seq=math.log(zone>>8,2)
			local oc=Duel.GetFieldCard(tp,LOCATION_SZONE,seq)
			if oc then
				Duel.SwapSequence(tc,oc)
			else
				Duel.MoveSequence(tc,seq)
			end
	end
end

function s.efilter(e,re,rp)
	return e:GetHandlerPlayer()==1-rp
end

function s.neospherefilter(c)
	return c:IsFaceup() and c:IsCode(60417395)
end

function s.immcon(e)
	return Duel.IsExistingMatchingCard(s.neospherefilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.activate_field(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.activate_field(e,tp,eg,ep,ev,re,r,rp)
	local darkness=Duel.CreateToken(tp, 81632161)
	Duel.SSet(tp, darkness)
end


function s.darkness_backrow_filter(_,c)
	return c:IsCode(511310101) or c:IsCode(511310105)  or c:IsCode(511310100)
	 or c:IsCode(511310104)  or c:IsCode(511310102)  or c:IsCode(511310103)

end

function s.monsterefffilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and not (c:GetFlagEffect(id)>0)
end

function s.raincrowfilter(c)
	return c:IsCode(511310108) and c:IsAbleToHand()
end

function s.bramblefilter(c)
	return c:IsCode(511310107) and c:IsFaceup()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 then return end
	--Boolean checks for the activation condition: b1, b2, b3
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.monsterefffilter,tp,LOCATION_MZONE,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.bramblefilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.raincrowfilter,tp,LOCATION_DECK,0,1,nil)


	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.monsterefffilter,tp,LOCATION_MZONE,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.bramblefilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.raincrowfilter,tp,LOCATION_DECK,0,1,nil)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,2)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

--op=0, target 1 monster you control, that monster gains the following effect:
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local tarc=Duel.SelectMatchingCard(tp,s.monsterefffilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	tarc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.rvtg)
	e1:SetOperation(s.rvop)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tarc:RegisterEffect(e1)


	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

--op=1, add 1 "Darkness Raincrow" from your Deck to your Hand.
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp, s.raincrowfilter, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end


function s.rvtg(e,tp,ev,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_SZONE,0,1,nil) end
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_SZONE,0,1,1,nil)
end
