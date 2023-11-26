--Go Fishing

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

local TERORKING_SALMON=78060096


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)



		-- Once per turn, when you Normal Summon a Water monster, you can roll a die. Reveal that many cards from the top of your Deck and add 1 WATER monster from among those to your hand,
		--then shuffle the rest back into the Deck.  Once per Duel, If you control "Terrorking Salmon",
		--you can destroy 1 Fish monster from among the cards revealed, and if you do, give "Terrorking Salmon" ATK/DEF equal to the ATK/DEF of the destroyed card until the end of the next turn.
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		-- e2:SetProperty(EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2,tp)


	end
	e:SetLabel(1)
end

function s.adfil(c)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WATER)
end

function s.desfilter(c)
	return c:IsDestructable() and c:IsRace(RACE_FISH)
end

function s.futerrorkingfilter(c)
	return c:IsFaceup() and c:IsCode(TERORKING_SALMON)
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsAttribute(ATTRIBUTE_WATER) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) and (Duel.GetFlagEffect(tp, id+3)==0)
end

function s.summon_salmon_filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCode(TERORKING_SALMON) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		if kdr.IsQuestDone(tp) then
			Duel.Hint(HINT_CARD,tp,id+1)
		else
			Duel.Hint(HINT_CARD,tp,id)
		end

		local g=Duel.TossDice(tp,1)

		if g>Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then
			g=Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)
		end

		Duel.ConfirmDecktop(tp,g)
		local tc=Duel.GetDecktopGroup(tp,g):Filter(s.adfil,nil)

		if #tc>0 then
			if #tc:Filter(Card.IsCode,nil,TERORKING_SALMON)>0 and (not kdr.IsQuestDone(tp)) then
				s.upgrade(e, tp, eg, ep, ev, re, r, rp)
				if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local temp1=Duel.GetMatchingGroup(s.summon_salmon_filter,tp, LOCATION_HAND+LOCATION_DECK, 0,nil,e,tp)
					local temp=tc:Filter(Card.IsCode,nil,TERORKING_SALMON):AddCard(temp1)
					local salmon=temp:Select(tp,1,1,nil)
					if salmon then
						Duel.SpecialSummon(salmon, SUMMON_TYPE_SPECIAL, tp, tp, false,false,POS_FACEUP)
						if salmon:GetFirst():GetPreviousLocation()==LOCATION_HAND then
							Duel.Draw(tp, 1, REASON_EFFECT)
						end
						tc=tc:RemoveCard(salmon)
					end
				end
			end
			if #tc>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local ath=tc:Select(tp,1,1,nil)
			Duel.SendtoHand(ath, tp, REASON_EFFECT)

			-- Debug.Message(kdr.IsQuestDone(tp))
			-- Debug.Message(Duel.IsExistingMatchingCard(s.futerrorkingfilter, tp, LOCATION_MZONE, 0, 1, nil))
			-- Debug.Message(#tc:Filter(s.desfilter,nil)>0)
			-- Debug.Message(Duel.GetFlagEffect(tp, id+2)==0)

			if (kdr.IsQuestDone(tp) ) and Duel.IsExistingMatchingCard(s.futerrorkingfilter, tp, LOCATION_MZONE, 0, 1, nil) and (#tc:Filter(s.desfilter,nil)>0) and (Duel.GetFlagEffect(tp, id+2)==0) then
				if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
					local descardgroup=tc:Filter(s.desfilter,nil)
					local descard=descardgroup:Select(tp,1,1,nil)
					if Duel.Destroy(descard,REASON_EFFECT) then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
						local salmon=Duel.SelectMatchingCard(tp, s.futerrorkingfilter, tp, LOCATION_MZONE, 0, 1, 1, false, nil)
						if salmon then
							local e1=Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_SINGLE)
							e1:SetCode(EFFECT_UPDATE_ATTACK)
							e1:SetValue(descard:GetFirst():GetAttack())
							e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
							salmon:GetFirst():RegisterEffect(e1)

							local e2=e1:Clone()
							e2:SetCode(EFFECT_UPDATE_DEFENSE)
							e2:SetValue(descard:GetFirst():GetDefense())
							salmon:GetFirst():RegisterEffect(e2)

							Duel.RegisterFlagEffect(tp, id+2, 0, 0, 0)

						end
					end


				end
			end
		end
		end

		Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)

	end
end




function s.upgrade(e,tp,eg,ep,ev,re,r,rp)
		kdr.CompleteQuest(tp,e:GetHandler(),e)
		e:GetHandler():Recreate(id+1)
		Duel.Hint(HINT_SKILL_REMOVE,tp,id)
		Duel.Hint(HINT_SKILL_FLIP,tp,(id+1)|(1<<32))
		Duel.Hint(HINT_SKILL,tp,id+1)
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


function s.discardsalmonfilter(c)
	return c:IsDiscardable(REASON_COST) and c:IsCode(TERORKING_SALMON)
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0  then return end
	--Boolean checks for the activation condition: b1, b2, b3, b4

	--Once per turn: You can discard 1 "Terrorking Salmon" to activate this skill's ➀ effect, and add 5 to the result of the dice roll.
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and (kdr.IsQuestDone(tp) ) and
			Duel.IsExistingMatchingCard(s.discardsalmonfilter, tp, LOCATION_HAND, 0, 1, nil)
			and  Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil)



	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	if kdr.IsQuestDone(tp) then
		Duel.Hint(HINT_CARD,tp,id+1)
	else
		Duel.Hint(HINT_CARD,tp,id)
	end
	--Once per turn: You can discard 1 "Terrorking Salmon" to activate this skill's ➀ effect, and add 5 to the result of the dice roll.
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and (kdr.IsQuestDone(tp) ) and
			Duel.IsExistingMatchingCard(s.discardsalmonfilter, tp, LOCATION_HAND, 0, 1, nil) and
			 Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil)



	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end



--Once per turn: You can discard 1 "Terrorking Salmon" to activate this skill's ➀ effect, and add 5 to the result of the dice roll.
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp, s.discardsalmonfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
	if #g>0 then
		if Duel.SendtoGrave(g, REASON_DISCARD) then



			local g=Duel.TossDice(tp,1)
			g=g+5

			if g>Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then
				g=Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)
			end

			Duel.ConfirmDecktop(tp,g)
			local tc=Duel.GetDecktopGroup(tp,g):Filter(s.adfil,nil)

			if #tc>0 then

				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local ath=tc:Select(tp,1,1,nil)
				Duel.SendtoHand(ath, tp, REASON_EFFECT)

				if (kdr.IsQuestDone(tp) ) and Duel.IsExistingMatchingCard(s.futerrorkingfilter, tp, LOCATION_MZONE, 0, 1, nil) and (#tc:Filter(s.desfilter,nil)>0) and (Duel.GetFlagEffect(tp, id+2)==0) then
					if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
						local descard=tc:Filter(s.desfilter,nil):Select(tp,1,1,nil)
						if Duel.Destroy(descard,REASON_EFFECT) then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
							local salmon=Duel.SelectMatchingCard(tp, s.futerrorkingfilter, tp, LOCATION_MZONE, 0, 1, 1, false, nil)
							if salmon then
								local e1=Effect.CreateEffect(e:GetHandler())
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetCode(EFFECT_UPDATE_ATTACK)
								e1:SetValue(descard:GetFirst():GetAttack())
								e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
								salmon:GetFirst():RegisterEffect(e1)

								local e2=e1:Clone()
								e2:SetCode(EFFECT_UPDATE_DEFENSE)
								e2:SetValue(descard:GetFirst():GetDefense())
								salmon:GetFirst():RegisterEffect(e2)

								Duel.RegisterFlagEffect(tp, id+2, 0, 0, 0)


							end
						end


					end
				end
			end








	end

	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
