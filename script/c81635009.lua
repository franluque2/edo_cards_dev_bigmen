--Infinite Galaxy
Duel.LoadScript("big_aux.lua")


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
	aux.AddSkillProcedure(c,2,false,s.flipcon3,s.flipop3)

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
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_DRAW)
	e1:SetCondition(s.flipcon2)
	e1:SetOperation(s.flipop2)
	Duel.RegisterEffect(e1,tp)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.atohand(code,tp)
	local token=Duel.CreateToken(tp, code)
	Duel.SendtoHand(token, tp, REASON_RULE)
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+1)==0
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_CARD,tp,id)
	local num1=Duel.GetRandomNumber(1, #CustomArchetype.kdr_ct_number )
	local num2=Duel.GetRandomNumber(1, #CustomArchetype.kdr_ct_number )
	while num2==num1 do
		num2=Duel.GetRandomNumber(1, #CustomArchetype.kdr_ct_number )
	end
	local num3=Duel.GetRandomNumber(1, #CustomArchetype.kdr_ct_number )
	while num3==num2 or num3==num1 do
		num3=Duel.GetRandomNumber(1, #CustomArchetype.kdr_ct_number )
	end

	local option1=Duel.CreateToken(tp, CustomArchetype.kdr_ct_number[num1])
	local option2=Duel.CreateToken(tp, CustomArchetype.kdr_ct_number[num2])
	local option3=Duel.CreateToken(tp, CustomArchetype.kdr_ct_number[num3])

	local g=Group.CreateGroup()
	g:AddCard(option1)
	g:AddCard(option2)
	g:AddCard(option3)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=g:Select(tp, 1, 1,nil):GetFirst()
	local  card=g:GetFirst()
	while card do
		if card==tc then
			Duel.SendtoDeck(card, tp, SEQ_DECKTOP, REASON_RULE)
		else
			Duel.SpecialSummon(card, SUMMON_TYPE_SPECIAL, tp, tp, true, false, POS_FACEUP)
		end
	card=g:GetNext()
	end


	Duel.RegisterFlagEffect(ep,id+1,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.canchangelevelfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_LINK)
end


--effects to activate during the main phase go here
function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+2)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.canchangelevelfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)



--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above
local b1=Duel.GetFlagEffect(tp,id+2)==0
and Duel.IsExistingMatchingCard(s.canchangelevelfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)


		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(s.canchangelevelfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	if #g>0 then
		Duel.Hint(HINT_NUMBER,tp,HINTMSG_LVRANK)
		local level=Duel.AnnounceLevel(tp)
		local tc=g:GetFirst()
		while tc do
			if tc:IsType(TYPE_XYZ) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_RANK_LEVEL_S)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_CHANGE_RANK_FINAL)
				e2:SetValue(level)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)


		else
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
			e2:SetValue(level)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		tc=g:GetNext()

		end
	end

	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
