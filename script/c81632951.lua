--Rising of the Great Sphinx
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
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)



		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
		e8:SetCondition(s.setcon)
		e8:SetOperation(s.pyramidpop)
		Duel.RegisterEffect(e8,tp)


		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetTargetRange(LOCATION_ONFIELD,0)
		e2:SetCondition(s.immcon)
		e2:SetTarget(s.sphinxfilter)
		e2:SetValue(aux.TRUE)
		Duel.RegisterEffect(e2,tp)

		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		Duel.RegisterEffect(e3, tp)



		local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(0xe2)
        Duel.RegisterEffect(e5,tp)

		local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_RACE)
        e6:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e6:SetValue(RACE_ROCK)
        Duel.RegisterEffect(e6,tp)



	end
	e:SetLabel(1)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+4)==0
			and Duel.IsExistingMatchingCard(s.fucodefilter,tp,LOCATION_ONFIELD,0,1,nil,15013468)
			and Duel.IsExistingMatchingCard(s.fucodefilter,tp,LOCATION_ONFIELD,0,1,nil,51402177)
			and Duel.GetLocationCount(tp, LOCATION_SZONE)>0
end


function s.immcon(e)
	return Duel.IsExistingMatchingCard(s.pyramidfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

function s.sphinxfilter(_,c)
	return (c:IsCode(15013468) or c:IsCode(51402177)) and c:IsFaceup()

end

function s.pyramidfilter(c)
	return c:IsCode(53569894) and c:IsFaceup()
end

function s.pyramidpop(e,tp,eg,ev,ep,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		Duel.Hint(HINT_CARD, tp, id)

		local oops=Duel.CreateToken(tp, 55573346)
		Duel.SSet(tp, oops)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		oops:RegisterEffect(e2)

		Duel.RegisterFlagEffect(tp,id+4,0,0,0)
	end
end

function s.archetypefilter(c)
	return c:IsSetCard(0x5c) and c:IsLevel(10)
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.setpyramid(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(s.archetypefilter, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.setpyramid(e,tp,eg,ep,ev,re,r,rp)
	local pyramid=Duel.CreateToken(tp, 53569894)
	Duel.SSet(tp, pyramid)
end

function s.sumfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP) and (c:IsCode(15013468) or c:IsCode(51402177))
end

function s.fucodefilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end

function s.pyramidbanish(c)
	return c:IsCode(53569894) and c:IsAbleToRemove()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+3)>0  then return end
	--Boolean checks for the activation condition: b1, b2
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.pyramidfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.fucodefilter,tp,LOCATION_ONFIELD,0,1,nil,15013468)
			and Duel.IsExistingMatchingCard(s.fucodefilter,tp,LOCATION_ONFIELD,0,1,nil,51402177)

	local b3=Duel.GetFlagEffect(tp, id+3)==0
		and Duel.IsExistingMatchingCard(s.fucodefilter, tp, LOCATION_MZONE, 0, 1, nil, 87997872)
		and Duel.IsExistingMatchingCard(s.pyramidbanish,tp,LOCATION_GRAVE,0,1,nil)

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.pyramidfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.fucodefilter,tp,LOCATION_ONFIELD,0,1,nil,15013468)
			and Duel.IsExistingMatchingCard(s.fucodefilter,tp,LOCATION_ONFIELD,0,1,nil,51402177)

	local b3=Duel.GetFlagEffect(tp, id+3)==0
		and Duel.IsExistingMatchingCard(s.fucodefilter, tp, LOCATION_MZONE, 0, 1, nil, 87997872)
		and Duel.IsExistingMatchingCard(s.pyramidbanish,tp,LOCATION_GRAVE,0,1,nil)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
								  {b2,aux.Stringid(id,2)},
									{b3, aux.Stringid(id, 3)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end

--Special Summon 1 "Andro Sphinx" or "Sphinx Teleia" that is banished or in your GY.
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, 1,1,false,nil,e,tp)

	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end

	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)


end

function s.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end

function s.target(e,c)
	return c:IsSetCard(0x5c) and c:IsFaceup()
end
-- Switch all monsters your opponent controls to DEF Position (if any), and until the end of this turn,
--when a "Sphinx" monster you control attacks a Defense Position monster your opponent controls, inflict piercing battle damage to your opponent.
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)


	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.SelectMatchingCard(tp, s.pyramidbanish, tp, LOCATION_GRAVE, 0, 1,1,false,nil)

	if Duel.Remove(g, POS_FACEUP, REASON_COST) then
		local tc=Duel.SelectMatchingCard(tp, s.fucodefilter, tp,LOCATION_MZONE,0,1,1,false,nil,87997872):GetFirst()
		if tc then
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetDescription(3110)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_IMMUNE_EFFECT)
			e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e3:SetRange(LOCATION_MZONE)
			e3:SetValue(s.efilter)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			e3:SetOwnerPlayer(tp)
			tc:RegisterEffect(e3)
		end
	end

	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
