--Look Ma, No Hands!

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



		--Whenever you draw a level 4 or lower monster (including in your opening hand), send it to the GY.
		s.discard_from_starting_hand(e,tp,eg,ep,ev,re,r,rp)


		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_DRAW)
		e2:SetOperation(s.discard)
		Duel.RegisterEffect(e2,tp)


		--Requirement: Have 3 "Skull Servant" in your GY. Reward: Upgrade this skill into "Powers of the Fallen King"
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_DELAY)
		e3:SetCode(EVENT_TO_GRAVE)
		e3:SetOperation(s.upgrade)
		Duel.RegisterEffect(e3,tp)


		-- (QUEST) “Skull Servant” you control gain 1000 ATK for each “Skull Servant” in your GY.
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetTargetRange(LOCATION_MZONE,0)
		e4:SetTarget(s.efilter)
		e4:SetValue(s.eval)
		Duel.RegisterEffect(e4,tp)



	end
	e:SetLabel(1)
end

function s.efilter(e,c)
	return c:IsFaceup() and c:IsCode(CARD_SKULL_SERVANT)
end

function s.efilter2(c)
	return c:IsFaceup() and c:IsCode(CARD_SKULL_SERVANT)
end


function s.eval(e,c)
	if Duel.GetFlagEffect(c:GetControler(), id+8)>8 then
		return 0
	end
	return Duel.GetMatchingGroupCount(Card.IsCode, c:GetControler(), LOCATION_GRAVE, 0, nil, CARD_SKULL_SERVANT)*1000
end


function s.sendfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4)
end

function s.upgrade(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return end
	if kdr.IsQuestDone(ep) then return end
	if Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_GRAVE, 0, nil, CARD_SKULL_SERVANT)>2 then
		kdr.CompleteQuest(ep,e:GetHandler(),e)
		e:GetHandler():Recreate(id+1)
		Duel.Hint(HINT_SKILL_REMOVE,ep,id)
		Duel.Hint(HINT_SKILL_FLIP,ep,(id+1)|(1<<32))
		Duel.Hint(HINT_SKILL,ep,id+1)
	end
end

function s.discard_from_starting_hand(e,tp,eg,ep,ev,re,r,rp)
	if kdr.IsQuestDone(tp) then
		Duel.Hint(HINT_CARD,tp,id+1)
	else
		Duel.Hint(HINT_CARD,tp,id)
	end
	local g=Duel.GetMatchingGroup(s.sendfilter, tp, LOCATION_HAND, 0, nil)
	if #g>0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
	end
end

function s.discard(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return end
	local rg=eg:Filter(s.sendfilter,nil)
	if #rg==0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.ConfirmCards(1-tp, rg)
	Duel.SendtoGrave(rg, REASON_EFFECT)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	if kdr.IsQuestDone(tp) then
		Duel.Hint(HINT_CARD,tp,id+1)
	else
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.skull_servant_banish_filter(c)
	return c:IsCode(CARD_SKULL_SERVANT) and c:IsAbleToRemoveAsCost()
end

function s.skull_servant_send_filter(c)
	return c:IsCode(CARD_SKULL_SERVANT) and c:IsAbleToGrave()
end

function s.skull_servant_summon_filter(c,e,tp)
	return c:IsCode(CARD_SKULL_SERVANT) and  c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end


function s.summonfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0 then return end
	--Boolean checks for the activation condition: b1, b2, b3, b4

	--Once per turn, you can Special Summon 1 level 4 or lower Zombie tyoe monster from your GY, but you cannot Normal Summon/Set monsters the turn you activate this effect.
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.summonfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
						and Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0

	-- Once per Turn, and up to Thrice per Duel, you can send 1 "Skull Servant" from your Deck to the GY.
	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.GetFlagEffect(tp, id+5)<3
			and Duel.IsExistingMatchingCard(s.skull_servant_send_filter,tp,LOCATION_DECK,0,1,nil)

	-- Once per Duel, if you have at least 3 "Skull Servant" in your GY: you can Special Summon 1 "Skull Servant" from your GY.
	local b3=Duel.GetFlagEffect(tp,id+3)==0
			and	 (Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_GRAVE, 0, nil, CARD_SKULL_SERVANT)>2)
			and  Duel.IsExistingMatchingCard(s.skull_servant_summon_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)

	-- (QUEST) Once per turn, you can banish 1 “Skull Servant” from your GY to grant 1 “Skull Servant” you control 2000 ATK until the end of the next turn.
	local b4=Duel.GetFlagEffect(tp,id+4)==0
			and kdr.IsQuestDone(tp)
			and Duel.IsExistingMatchingCard(s.efilter2,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.skull_servant_banish_filter,tp,LOCATION_GRAVE,0,1,nil)


	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	if kdr.IsQuestDone(tp) then
		Duel.Hint(HINT_CARD,tp,id+1)
	else
		Duel.Hint(HINT_CARD,tp,id)
	end
	--Once per turn, you can Special Summon 1 level 4 or lower Zombie tyoe monster from your GY, but you cannot Normal Summon/Set monsters the turn you activate this effect.
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.summonfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
						and Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0

	-- Once per Turn, and up to Thrice per Duel, you can send 1 "Skull Servant" from your Deck to the GY.
	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.GetFlagEffect(tp, id+5)<3
			and Duel.IsExistingMatchingCard(s.skull_servant_send_filter,tp,LOCATION_DECK,0,1,nil)

	-- Once per Duel, if you have at least 3 "Skull Servant" in your GY: you can Special Summon 1 "Skull Servant" from your GY.
	local b3=Duel.GetFlagEffect(tp,id+3)==0
			and	 (Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_GRAVE, 0, nil, CARD_SKULL_SERVANT)>2)
			and  Duel.IsExistingMatchingCard(s.skull_servant_summon_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)

	-- (QUEST) Once per turn, you can banish 1 “Skull Servant” from your GY to grant 1 “Skull Servant” you control 2000 ATK until the end of the next turn.
	local b4=Duel.GetFlagEffect(tp,id+4)==0
			and kdr.IsQuestDone(tp)
			and Duel.IsExistingMatchingCard(s.efilter2,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.skull_servant_banish_filter,tp,LOCATION_GRAVE,0,1,nil)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
									 {b3,aux.Stringid(id,2)},
								  {b4,aux.Stringid(id,3)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	end
end



--Special Summon 1 level 4 or lower Zombie tyoe monster from your GY, but you cannot Normal Summon/Set monsters the turn you activate this effect
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp, s.summonfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		Duel.RegisterEffect(e2,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,4),nil)

	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


-- Once per Turn, and up to Thrice per Duel, you can send 1 "Skull Servant" from your Deck to the GY.
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.GetFirstMatchingCard(s.skull_servant_send_filter, tp, LOCATION_DECK, 0, nil)
	if g then
		Duel.SendtoGrave(g, REASON_EFFECT)
	end
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	Duel.RegisterFlagEffect(tp,id+5,0,0,0)

end

--Once per Duel, if you have at least 3 "Skull Servant" in your GY: you can Special Summon 1 "Skull Servant" from your GY.
function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp, s.skull_servant_summon_filter, tp, LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
	end

	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

-- (QUEST) Once per turn, you can banish 1 “Skull Servant” from your GY to grant 1 “Skull Servant” you control 2000 ATK until the end of the next turn.
function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp, s.skull_servant_banish_filter, tp, LOCATION_GRAVE, 0, 1,1,false,nil)
	if #g>0 then
		Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
		local tc=Duel.SelectMatchingCard(tp, s.efilter2, tp, LOCATION_MZONE, 0, 1,1,false,nil)
		if #tc>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:GetFirst():RegisterEffect(e1)
		end
	end

	Duel.RegisterFlagEffect(tp,id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
