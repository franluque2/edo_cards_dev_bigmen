--Relativity Duel Theory
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

		-- local e3=Effect.CreateEffect(e:GetHandler())
		-- e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		-- e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		-- e3:SetCountLimit(1)
		-- e3:SetCondition(s.spcon)
		-- e3:SetOperation(s.spop)
		-- Duel.RegisterEffect(e3,tp)
	end
	e:SetLabel(1)
end

-- function s.spcon(e,tp,eg,ep,ev,re,r,rp)
-- 	return Duel.GetFlagEffect(id,tp)~=0 and Duel.IsTurnPlayer(1-tp)
-- end
--
-- --Once per turn, at the start of your Opponent's Battle Phase, you can banish 1 monster you control. Return that monster to your field during the End Phase.
--
--
-- function s.spop(e,tp,eg,ep,ev,re,r,rp)
-- 	if Duel.SelectYesNo(tp, aux.Stringid(id, 5)) then
-- 		Duel.Hint(HINT_CARD,tp,id)
-- 		 local tc=Duel.SelectMatchingCard(tp, Card.IsAbleToRemove, tp, LOCATION_MZONE, 0, 1, 1,false,nil):GetFirst()
-- 			if tc and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
-- 			local e1=Effect.CreateEffect(e:GetHandler())
-- 			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
-- 			e1:SetCode(EVENT_PHASE+PHASE_END)
-- 			e1:SetReset(RESET_PHASE+PHASE_END)
-- 			e1:SetLabelObject(tc)
-- 			e1:SetCountLimit(1)
-- 			e1:SetOperation(s.retop)
-- 			Duel.RegisterEffect(e1,tp)
-- 		end
-- 	end
-- end
--
-- function s.retop(e,tp,eg,ep,ev,re,r,rp)
-- 	Duel.ReturnToField(e:GetLabelObject())
-- end


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
	local relavfield=Duel.CreateToken(tp,511000479)
	Duel.ActivateFieldSpell(relavfield,e,tp,eg,ep,ev,re,r,rp)
end

function s.addcontspellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end

function s.fucontspellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsFaceup()
end

function s.addconttrapfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end

function s.fuconttrapfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsFaceup()
end

function s.sumfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.fumonsterfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and
	 	Duel.GetFlagEffect(tp, id+4)>0 and Duel.GetFlagEffect(tp, id+5)>0 then return end
	--Boolean checks for the activation condition: b1, b2
	local b1=Duel.GetFlagEffect(ep,id+1)==0
			and ((Duel.GetFlagEffect(ep,id+3)==0 and Duel.IsExistingMatchingCard(s.fumonsterfilter,tp,LOCATION_MZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addcontspellfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0)
			or (Duel.GetFlagEffect(ep,id+4)==0 and Duel.IsExistingMatchingCard(s.fucontspellfilter,tp,LOCATION_SZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addconttrapfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0)
			or (Duel.GetFlagEffect(ep,id+5)==0 and Duel.IsExistingMatchingCard(s.fuconttrapfilter,tp,LOCATION_SZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0))
	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(aux.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_MONSTER)
			and Duel.IsExistingMatchingCard(s.fucontspellfilter,tp,LOCATION_SZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.fuconttrapfilter,tp,LOCATION_SZONE,0,1,nil)
			and Duel.GetLocationCount(tp, LOCATION_SZONE)>0



	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(ep,id+1)==0
			and ((Duel.GetFlagEffect(ep,id+3)==0 and Duel.IsExistingMatchingCard(s.fumonsterfilter,tp,LOCATION_MZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addcontspellfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0)
			or (Duel.GetFlagEffect(ep,id+4)==0 and Duel.IsExistingMatchingCard(s.fucontspellfilter,tp,LOCATION_SZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addconttrapfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0)
			or (Duel.GetFlagEffect(ep,id+5)==0 and Duel.IsExistingMatchingCard(s.fuconttrapfilter,tp,LOCATION_SZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0))

	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(aux.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_MONSTER)
			and Duel.IsExistingMatchingCard(s.fucontspellfilter,tp,LOCATION_SZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.fuconttrapfilter,tp,LOCATION_SZONE,0,1,nil)
			and Duel.GetLocationCount(tp, LOCATION_SZONE)>0


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,4)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

	local b1=Duel.GetFlagEffect(ep,id+3)==0 and Duel.IsExistingMatchingCard(s.fumonsterfilter,tp,LOCATION_MZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addcontspellfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(ep,id+4)==0 and Duel.IsExistingMatchingCard(s.fucontspellfilter,tp,LOCATION_SZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addconttrapfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0
	local b3=Duel.GetFlagEffect(ep,id+5)==0 and Duel.IsExistingMatchingCard(s.fuconttrapfilter,tp,LOCATION_SZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
													  {b2,aux.Stringid(id,2)},
														{b3,aux.Stringid(id,3)})
						op=op-1

	if op==0 then
		local spell=Duel.SelectMatchingCard(tp, s.addcontspellfilter, tp, LOCATION_DECK, 0, 1, 1,false,nil)
		Duel.SSet(tp, spell)
		Duel.RegisterFlagEffect(tp,id+3,0,0,0)
	elseif op==1 then
		local trap=Duel.SelectMatchingCard(tp, s.addconttrapfilter, tp, LOCATION_DECK, 0, 1, 1,false,nil)
		Duel.SSet(tp, trap)
		Duel.RegisterFlagEffect(tp,id+4,0,0,0)
	elseif op==2 then
		local mons=Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_GRAVE+LOCATION_HAND, 0, 1, 1,false,nil,e,tp)
		Duel.SpecialSummon(mons,0,tp,tp,false,false,POS_FACEUP)
		Duel.RegisterFlagEffect(tp,id+5,0,0,0)
	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local bter=Duel.CreateToken(tp, 81632120)
	Duel.SSet(tp, bter)
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
