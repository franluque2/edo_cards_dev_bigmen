--Mark of the Monkey
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

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CHANGE_RACE)
		e3:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
		e3:SetTarget(aux.TargetBoolFunction(s.primineral_baboon_filter_type))
		e3:SetValue(RACE_BEAST)
		Duel.RegisterEffect(e3,tp)
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

	local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 33537328)
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

function s.beastfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
end

function s.monsterfilter(c)
	return c:IsFaceup() and c:HasLevel()
end

function s.zeman_ape_king_filter(c)
	return c:IsCode(22858242) and c:IsFaceup()
end


function s.zeman_ape_king_affected_filter(c)
	return c:IsCode(22858242) and c:IsFaceup() and (c:GetFlagEffect(id)>0)
end

function s.high_level_filter(c)
	return c:HasLevel() and c:IsLevelAbove(5) and c:IsFaceup()
end

function s.primineral_baboon_filter_type(c)
	return c:IsFaceup() and (c:IsCode(46668237) or c:IsCode(65303664) or c:IsCode(55705473) or c:IsCode(49729312)
	 		or c:IsCode(37021315))
end

function s.primineral_baboon_filter(c)
	return c:IsAbleToHand() and (c:IsCode(46668237) or c:IsCode(65303664) or c:IsCode(55705473) or c:IsCode(49729312)
	 		or c:IsCode(37021315))
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and
	 	Duel.GetFlagEffect(tp, id+4)>0 and Duel.GetFlagEffect(tp, id+5)>0 then return end
	--Boolean checks for the activation condition: b1, b2, b3
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.beastfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp, LOCATION_MZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.zeman_ape_king_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.primineral_baboon_filter,tp,LOCATION_DECK,0,1,nil)

	local b4=Duel.GetFlagEffect(tp, id+4)==0
		and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	local b5=Duel.GetFlagEffect(tp, id+5)==0
		and Duel.IsExistingMatchingCard(s.zeman_ape_king_filter,tp,LOCATION_MZONE,0,1,nil)
		and not Duel.IsExistingMatchingCard(s.zeman_ape_king_affected_filter,tp,LOCATION_MZONE,0,1,nil)


	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4 or b5)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.beastfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp, LOCATION_MZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.zeman_ape_king_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.primineral_baboon_filter,tp,LOCATION_DECK,0,1,nil)

	local b4=Duel.GetFlagEffect(tp, id+4)==0
		and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	local b5=Duel.GetFlagEffect(tp, id+5)==0
		and Duel.IsExistingMatchingCard(s.zeman_ape_king_filter,tp,LOCATION_MZONE,0,1,nil)
		and not Duel.IsExistingMatchingCard(s.zeman_ape_king_affected_filter,tp,LOCATION_MZONE,0,1,nil)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,2)},
								  {b4,aux.Stringid(id,4)},
									{b5,aux.Stringid(id,3)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	elseif op==4 then
		s.operation_for_res4(e,tp,eg,ep,ev,re,r,rp)
	end
end

--op=0, Special Summon 1 Level 4 or lower Beast from your Hand or GY ignoring its summoning conditions
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.beastfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

--op=1, target 1 monster you control, declare a level from 1-4,
-- until the end of this turn, that monster becomes that level and becomes a DARK Tuner monster
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.monsterfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
		local lvl=Duel.AnnounceLevel(tp,1,4)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(ATTRIBUTE_DARK)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e3)
	end
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

--op=2,Add 1 "Primineral" monster or 1 "Baboon" monster from your Deck to your Hand.
function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp, s.primineral_baboon_filter, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end

--op=3 set 1 "Contaminated Earth" from outside the duel to your Spell/Trap Zone.
function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	local cearth=Duel.CreateToken(tp, 100000307)
	Duel.SSet(tp,cearth)
	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
end

--Target 1 "Zeman the Ape King" you control, it gains an effect.
function s.operation_for_res4(e,tp,eg,ep,ev,re,r,rp)
	local tarc=Duel.SelectMatchingCard(tp,s.zeman_ape_king_filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	tarc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)

	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetDescription(aux.Stringid(id, 5))
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e3:SetCountLimit(1)
	e3:SetCondition(s.chcon1)
	e3:SetOperation(s.chop1)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	tarc:RegisterEffect(e3)


	Duel.RegisterFlagEffect(tp,id+5,0,0,0)
end

function s.chcon1(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==1-tp and (re:IsActiveType(TYPE_MONSTER))
end
function s.chop1(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end

function s.desfilter(c)
	return c:IsFacedown()
end
function s.monfilter_deck(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(1-tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
		Duel.BreakEffect()
		if Duel.IsExistingMatchingCard(s.monfilter_deck,tp,LOCATION_DECK,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g2=Duel.SelectMatchingCard(tp,s.monfilter_deck,tp,LOCATION_DECK,0,1,1,nil)
			if #g2>0 then
				Duel.SendtoGrave(g2, REASON_EFFECT)
		end
	end
end
end
