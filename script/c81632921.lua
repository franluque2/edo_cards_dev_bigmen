--Bandits of the Shadows

local s,id=GetID()


function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,1,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
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
		e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id+1,0,0,0)

		local c=e:GetHandler()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2,tp)

end
e:SetLabel(1)
	end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
--
-- At the start of the duel, Special Summon 1 "Don Zaloog" from outside the duel
-- and set 1 "Mustering of the Dark Scorpions" to your Spell/Trap Zone from outside the duel.
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.summon_zaloog(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.summon_zaloog(e,tp,eg,ep,ev,re,r,rp)
	local zaloog=Duel.CreateToken(tp, 76922029)
	Duel.SpecialSummon(zaloog,0,tp,tp,false,false,POS_FACEUP)
end


function s.dscorpion_addfilter(c)
	return (c:IsSetCard(0x1a) or c:IsCode(76922029)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.dscorpion_filter(c)
	return c:IsSetCard(0x1a) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

function s.zaloogfilter(c)
	return c:IsCode(76922029) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

function s.dscorpion_or_zaloog_filter(c)
	return (c:IsSetCard(0x1a) or c:IsCode(76922029)) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

function s.dscorpionmustering_filter(c)
	return c:IsCode(68191243)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPT check
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+6)>0 and Duel.GetFlagEffect(tp, id+7) then return end
	local g=Duel.GetMatchingGroup(s.dscorpion_filter,tp,LOCATION_MZONE,0,nil)
	local cg= g:GetClassCount(Card.GetCode)==4
--
-- Once per turn, you can target a "Dark Scorpion" or "Don Zaloog" you control,
-- this turn that target can attack your opponent directly this turn.
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.dscorpion_or_zaloog_filter,tp,LOCATION_MZONE,0,1,nil)

-- Once per turn, if you control Don Zaloog and 4 "Dark Scorpion" monsters with different names,
-- you can set 1 "Dark Scorpion Combination" from outside the duel to your Spell/Trap Zone. It can be activated this turn.
	local b2=Duel.GetFlagEffect(tp, id+6)==0
		and cg
		and Duel.IsExistingMatchingCard(s.zaloogfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

		--Once per turn, if you control "Don Zaloog",
		--you can set 1 "Mustering of the Dark Scorpions" from your Deck or GY to your Spell/Trap Zone.

		local b3=Duel.GetFlagEffect(tp, id+7)==0
			and Duel.IsExistingMatchingCard(s.zaloogfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.dscorpionmustering_filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local g=Duel.GetMatchingGroup(s.dscorpion_filter,tp,LOCATION_MZONE,0,nil)
	local cg= g:GetClassCount(Card.GetCode)==4
--
-- Once per turn, you can target a "Dark Scorpion" or "Don Zaloog" you control,
-- this turn that target can attack your opponent directly this turn.

	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.dscorpion_or_zaloog_filter,tp,LOCATION_MZONE,0,1,nil)

-- Once per turn, if you control Don Zaloog and 4 "Dark Scorpion" monsters with different names,
-- you can set 1 "Dark Scorpion Combination" and "Dark Scorpion Retreat"
 -- from outside the duel to your Spell/Trap Zone. It can be activated this turn.
	local b2=Duel.GetFlagEffect(tp, id+6)==0
		and cg
		and Duel.IsExistingMatchingCard(s.zaloogfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>1

		--Once per turn, if you control "Don Zaloog",
		--you can set 1 "Mustering of the Dark Scorpions" from your Deck or GY to your Spell/Trap Zone.

		local b3=Duel.GetFlagEffect(tp, id+7)==0
			and Duel.IsExistingMatchingCard(s.zaloogfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.dscorpionmustering_filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)


		local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									  {b2,aux.Stringid(id,1)},
											{b3,aux.Stringid(id, 2)})
		op=op-1

	if op==0 then
			local scorpion=Duel.SelectMatchingCard(tp,s.dscorpion_or_zaloog_filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3205)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			scorpion:RegisterEffect(e1)
			--opt register
			Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	elseif op==1 then
			local combination=Duel.CreateToken(tp, 20858318)
			Duel.SSet(tp, combination, tp, true)
			local retreat=Duel.CreateToken(tp, 111203902)
			Duel.SSet(tp, retreat, tp, true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			combination:RegisterEffect(e2)
			local e3=e2:Clone()
			retreat:RegisterEffect(e3)
			Duel.RegisterFlagEffect(tp, id+6, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
	elseif op==2 then
		local tc=Duel.SelectMatchingCard(tp, s.dscorpionmustering_filter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
		Duel.SSet(tp, tc, tp, true)
		Duel.RegisterFlagEffect(tp, id+7, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
	end
end


--
-- Once per turn,
-- during your Standby Phase, add 1 random "Dark Scorpion" monster or "Don Zaloog" from your Deck to your Hand.

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetTurnPlayer()==tp and not (Duel.GetFlagEffect(tp,id+3)>0) then return end

	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.dscorpion_addfilter,tp,LOCATION_DECK,0,1,nil)


	return Duel.GetTurnPlayer()==tp and (b1)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,id)
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(s.dscorpion_addfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 then
			local cardnumber=Duel.GetRandomNumber(1, #g )
			local tc=g:GetFirst()
			while tc do
				if cardnumber==1 then
					Duel.SendtoHand(tc, tp, REASON_EFFECT)
				end
				cardnumber=cardnumber-1
				tc=g:GetNext()
			end
		end
		Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
end
