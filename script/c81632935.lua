--Mark of the High King
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
	end
	e:SetLabel(1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.activate_field(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 46263076)
	if g and #g>0 then
		for tc in g:Iter() do
			if tc:GetFlagEffect(id)==0 then
				tc:RegisterFlagEffect(id,0,0,0)
				local eff={tc:GetCardEffect()}
				for _,teh in ipairs(eff) do
					if teh:GetCode()&EFFECT_CANNOT_BE_BATTLE_TARGET==EFFECT_CANNOT_BE_BATTLE_TARGET then
						teh:Reset()
					end
				end
				local e3=Effect.CreateEffect(tc)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
				e3:SetRange(LOCATION_MZONE)
				e3:SetValue(1)
				tc:RegisterEffect(e3)
		end
	end
	end

	
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.field_filter(c)
	return c:IsType(TYPE_FIELD)
end
function s.activate_field(e,tp,eg,ep,ev,re,r,rp)
	local field=Duel.SelectMatchingCard(tp,s.field_filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if #field>0 then
		Duel.ActivateFieldSpell(field:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
	end
end


function s.monsterfilter(c)
	return c:IsFaceup() and c:HasLevel()
end


function s.high_level_filter(c)
	return c:HasLevel() and c:IsLevelAbove(5) and c:IsFaceup()
end

function s.archfiendfilter(c)
	return c:IsCode(99177923)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and
	 	Duel.GetFlagEffect(tp, id+4)>0 then return end
	--Boolean checks for the activation condition: b1, b2, b3
	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

	local b3=Duel.GetFlagEffect(ep,id+3)==0
			and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>3

	local b4=Duel.GetFlagEffect(ep, id+4)==0
		and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	return aux.CanActivateSkill(tp) and (b2 or b3 or b4)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

	local b3=Duel.GetFlagEffect(ep,id+3)==0
			and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>3

	local b4=Duel.GetFlagEffect(ep, id+4)==0
		and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	local op=Duel.SelectEffect(tp, {b2,aux.Stringid(id,0)},
								  {b3,aux.Stringid(id,2)},
								  {b4,aux.Stringid(id,3)})

	if op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	end
end


--op=1, target 1 monster you control, declare a level from 1-12,
-- until the end of this turn, that monster becomes that level and becomes a Dark Tuner monster
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.monsterfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
			local lvl=Duel.AnnounceLevel(tp,1,12)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lvl)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				local e3=e1:Clone()
				e3:SetCode(EFFECT_ADD_TYPE)
				e3:SetValue(TYPE_TUNER)
				tc:RegisterEffect(e3)
				local e4=e1:Clone()
				e4:SetCode(EFFECT_ADD_SETCODE)
				e4:SetValue(0x600)
				tc:RegisterEffect(e4)
				local e5=Effect.CreateEffect(e:GetHandler())
				e5:SetType(EFFECT_TYPE_SINGLE)
				e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
				e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e5:SetValue(s.synlimit)
				e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e5)
			end
		end
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x601)
end

--op=2, Send your entire hand to the underworld
function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	local hand=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_HAND, 0, nil)
	Duel.RemoveCards(hand)

	if Duel.IsExistingMatchingCard(s.archfiendfilter, tp, LOCATION_DECK, 0, 1, nil) then
		if Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
			local archfiend=Duel.SelectMatchingCard(tp,s.archfiendfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if archfiend then
				Duel.ShuffleDeck(tp)
				Duel.MoveSequence(archfiend,0)
				Duel.ConfirmDecktop(tp,1)
				Duel.Draw(tp, 1, REASON_EFFECT)
			end
		end
	end
	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end

--op=3 set 1 "Contaminated Earth" from outside the duel to your Spell/Trap Zone.
function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	local cearth=Duel.CreateToken(tp, 100000307)
	Duel.SSet(tp,cearth)
	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
end
