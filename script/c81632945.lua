--Doom of Atlantis
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
		-- local e8=Effect.CreateEffect(e:GetHandler())
		-- e8:SetType(EFFECT_TYPE_FIELD)
		-- e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		-- e8:SetCode(EFFECT_CANNOT_LOSE_LP)
		-- e8:SetTargetRange(1,0)
		-- e8:SetValue(s.cantlose)
		-- Duel.RegisterEffect(e8,tp)

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)


		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2,tp)

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCountLimit(1)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCondition(s.adcon2)
		e3:SetOperation(s.adop2)
		Duel.RegisterEffect(e3,tp)


		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_ADD_TYPE)
		e4:SetTargetRange(LOCATION_MZONE,0)
		e4:SetTarget(aux.TargetBoolFunction(s.levelfilter))
		e4:SetValue(TYPE_NORMAL)
		Duel.RegisterEffect(e4,tp)

		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_DAMAGE)
		e5:SetCondition(s.spcon)
		e5:SetOperation(s.spop)
		Duel.RegisterEffect(e5,tp)


		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_CANNOT_INACTIVATE)
		e6:SetValue(s.effectfilter)
		Duel.RegisterEffect(e6,tp)
		local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_CANNOT_DISEFFECT)
		e7:SetValue(s.effectfilter)
		Duel.RegisterEffect(e7,tp)


		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD)
		e8:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e8:SetTargetRange(LOCATION_MZONE,0)
		e8:SetTarget(s.rdtg)
		e8:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		Duel.RegisterEffect(e8,tp)
		end
e:SetLabel(1)
end

-- function s.cantlose(c,tp)
-- 	return not Duel.GetFlagEffect(tp, id+7)>0
-- end
function s.rdtg(e,c)
	return c:IsCode(7634581)
end

function s.etarget(c)
	return c:GetOverlayCount()~=0
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)

	local c6=(Duel.GetFlagEffect(tp, id+7)==0) and Duel.GetLP(tp)<=0 and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,nil,TYPE_FIELD)
		and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, 0, 3, nil)

	return ep==tp and c6
end

function s.notfield(c)
	return not c:IsType(TYPE_FIELD)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)

	if Duel.SelectYesNo(tp, aux.Stringid(id, 5)) then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.SetLP(tp, 4000)
		local g=Duel.GetMatchingGroup(s.etarget, tp, LOCATION_ONFIELD, 0, nil)
		if #g>0 then
			local tc=g:GetFirst()
			local overlays=tc:GetOverlayGroup()
			tc=g:GetNext()
			while tc do
				overlays:Merge(tc:GetOverlayGroup())
				tc=g:GetNext()
			end
			Duel.SendtoGrave(overlays, REASON_EFFECT)
		end
		local g2=Duel.GetMatchingGroup(s.notfield, tp, LOCATION_ONFIELD, 0, nil)
		Duel.RemoveCards(g2)

		local leviathan=Duel.CreateToken(tp, 81632154)
		Duel.SpecialSummon(leviathan,0,tp,tp,true,false,POS_FACEUP)
	end

	-- local e8=Effect.CreateEffect(e:GetHandler())
	-- e8:SetType(EFFECT_TYPE_FIELD)
	-- e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- e8:SetCode(EFFECT_CANNOT_LOSE_LP)
	-- e8:SetTargetRange(1,0)
	-- e8:SetValue(0)
	-- Duel.RegisterEffect(e8,tp)

	Duel.RegisterFlagEffect(tp,id+7,0,0,0)
end


function s.levelfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(6)
end


function s.atkfilter1(c,tp)
	return c:IsFaceup() and Duel.IsExistingTarget(s.atkfilter2,tp,LOCATION_MZONE,0,1,c,c:GetAttack())
end
function s.atkfilter2(c,atk)
	return c:IsFaceup() and c:GetAttack()==atk
end


function s.adcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.atkfilter1, tp, LOCATION_MZONE, 0, 1, nil,tp)
end

function s.adop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.SelectMatchingCard(tp, s.atkfilter1, tp, LOCATION_MZONE, 0, 1,1,false,nil,tp)
	if #g>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		g:GetFirst():RegisterEffect(e1)
	end
end


function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	if (not Duel.GetTurnPlayer()==tp) or (Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0 and Duel.GetFlagEffect(tp,id+5)>0) then return end

	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+4)==0
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391),tp,LOCATION_ONFIELD,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+5)==0
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,110000100),tp,LOCATION_ONFIELD,0,1,nil)


	return Duel.GetTurnPlayer()==tp and (b1 or b2 or b3)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+4)==0
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391),tp,LOCATION_ONFIELD,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+5)==0
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,110000100),tp,LOCATION_ONFIELD,0,1,nil)


	if b1 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif b2 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif b3 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

	local seal=Duel.CreateToken(tp, 48179391)
	Duel.ActivateFieldSpell(seal,e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp, id+3, 0, 0, 0)
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local seal=Duel.CreateToken(tp, 110000100)
	Duel.ActivateFieldSpell(seal,e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp, id+4, 0, 0, 0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	local seal=Duel.CreateToken(tp, 110000101)
	Duel.ActivateFieldSpell(seal,e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp, id+5, 0, 0, 0)
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.listsorisshunoros(c)
	return (Card.ListsCode(c,7634581) or c:IsCode(7634581)) and c:IsAbleToDeck() and not c:IsPublic()
end

function s.kyutora_or_gigas(c)
	return (c:IsCode(170000166) or c:IsCode(170000171)) and c:IsAbleToHand()
end

function s.serpentfilter(c)
	return c:IsCode(82103466) and c:IsAbleToHand()
end

function s.dexiafilter(c)
	return c:IsCode(170000168) and c:IsAbleToHand()
end

function s.aristerosfilter(c)
	return c:IsCode(170000169) and c:IsAbleToHand()
end

function s.callingfilter(c)
	return c:IsCode(170000174) and c:IsAbleToDeck() and not c:IsPublic()
end

function s.mirrorfilter(c)
	return c:IsCode(170000173) and c:IsAbleToHand()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPT check
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+1)>0 and Duel.GetFlagEffect(tp, id+6)>0 then return end

	--Once per turn, you can reveal 1 "Orichalcos Shunoros" or any card that lists "Orichalcos Shunoros"
	--in it's text, shuffle it into the deck, then add 1 "Orichalcos Kyutora" or "Orichalcos Gigas" from your Deck to your Hand.


	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.listsorisshunoros,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.kyutora_or_gigas,tp,LOCATION_DECK,0,1,nil)

			--Once per Duel, if you control "Orichalcos Shunoros" you can add either add 1 "Divine Serpent Geh" or 1 "Orichalcos Dexia" and "Orichalcos Aristeros" from your Deck to your Hand.

	local b2=Duel.GetFlagEffect(tp, id+1)==0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,7634581),tp,LOCATION_MZONE,0,1,nil)
		and (Duel.IsExistingMatchingCard(s.serpentfilter,tp,LOCATION_DECK,0,1,nil)
		or (Duel.IsExistingMatchingCard(s.dexiafilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.aristerosfilter,tp,LOCATION_DECK,0,1,nil))
	)
		--Once per Duel, you can reveal 1 "Mirror Knight Calling" in your Hand, add 1 "Orichalcos Mirror" from your Deck to your Hand, then shuffle the revealed monster into the Deck.

		local b3=Duel.GetFlagEffect(tp, id+6)==0
			and Duel.IsExistingMatchingCard(s.callingfilter,tp,LOCATION_HAND,0,1,nil)
			-- and Duel.IsExistingMatchingCard(s.mirrorfilter,tp,LOCATION_DECK,0,1,nil)


	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	--Once per turn, you can reveal 1 "Orichalcos Shunoros" or any card that lists "Orichalcos Shunoros"
	--in it's text, shuffle it into the deck, then add 1 "Orichalcos Kyutora" or "Orichalcos Gigas" from your Deck to your Hand.


	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.listsorisshunoros,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.kyutora_or_gigas,tp,LOCATION_DECK,0,1,nil)

			--Once per Duel, if you control "Orichalcos Shunoros" you can add either add 1 "Divine Serpent Geh" or 1 "Orichalcos Dexia" and "Orichalcos Aristeros" from your Deck to your Hand.

	local b2=Duel.GetFlagEffect(tp, id+1)==0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,7634581),tp,LOCATION_MZONE,0,1,nil)
		and (Duel.IsExistingMatchingCard(s.serpentfilter,tp,LOCATION_DECK,0,1,nil)
		or (Duel.IsExistingMatchingCard(s.dexiafilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.aristerosfilter,tp,LOCATION_DECK,0,1,nil))
	)
		--Once per Duel, you can reveal 1 "Mirror Knight Calling" in your Hand, add 1 "Orichalcos Mirror" from your Deck to your Hand, then shuffle the revealed monster into the Deck.

		local b3=Duel.GetFlagEffect(tp, id+6)==0
			and Duel.IsExistingMatchingCard(s.callingfilter,tp,LOCATION_HAND,0,1,nil)
			-- and Duel.IsExistingMatchingCard(s.mirrorfilter,tp,LOCATION_DECK,0,1,nil)


		local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									  {b2,aux.Stringid(id,1)},
										{b3,aux.Stringid(id,4)})
		op=op-1

	if op==0 then
		--Once per turn, you can reveal 1 "Orichalcos Shunoros" or any card that lists "Orichalcos Shunoros"
		--in it's text, shuffle it into the deck, then add 1 "Orichalcos Kyutora" or "Orichalcos Gigas" from your Deck to your Hand.

			local g=Duel.SelectMatchingCard(tp, s.listsorisshunoros, tp, LOCATION_HAND, 0, 1,1,false,nil)
			if #g>0 then
				Duel.ConfirmCards(1-tp, g)
				if Duel.SendtoDeck(g, tp,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
					local tc=Duel.SelectMatchingCard(tp, s.kyutora_or_gigas, tp, LOCATION_DECK, 0, 1,1,false,nil)
					if Duel.SendtoHand(tc, tp,REASON_EFFECT)>0 then
						Duel.ConfirmCards(1-tp, tc)
					end
				end
			end
			Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	elseif op==1 then
			--Once per Duel, if you control "Orichalcos Shunoros" you can add either add 1 "Divine Serpent Geh" or 1 "Orichalcos Dexia" and "Orichalcos Aristeros" from your Deck to your Hand.
		local g1=Duel.IsExistingMatchingCard(s.serpentfilter,tp,LOCATION_DECK,0,1,nil)
		local g2=Duel.IsExistingMatchingCard(s.dexiafilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.aristerosfilter,tp,LOCATION_DECK,0,1,nil)

		local op2=Duel.SelectEffect(tp, {g1,aux.Stringid(id,2)},
									  {g2,aux.Stringid(id,3)})

		op2=op2-1

		if op2==0 then
			local g=Duel.SelectMatchingCard(tp, s.serpentfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
			if #g>0 then
					if Duel.SendtoHand(g, tp,REASON_EFFECT)>0 then
						Duel.ConfirmCards(1-tp, tc)
					end
			end

		elseif op2==1 then
			local g=Duel.SelectMatchingCard(tp, s.dexiafilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
			local g2=Duel.SelectMatchingCard(tp, s.aristerosfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
			g:Merge(g2)
					if Duel.SendtoHand(g, tp,REASON_EFFECT)>0 then
						Duel.ConfirmCards(1-tp, g)
					end
			end
		Duel.RegisterFlagEffect(tp,id+1,0,0,0)
	elseif op==2 then
		--Once per Duel, you can reveal 1 "Mirror Knight Calling" in your Hand, you can add 1 "Orichalcos Mirror" from your Deck to your Hand, then shuffle the revealed monster into the Deck.
		local g=Duel.SelectMatchingCard(tp, s.callingfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
		if #g>0 then
			Duel.ConfirmCards(1-tp, g)
			if (Duel.SendtoDeck(g, tp,SEQ_DECKSHUFFLE,REASON_EFFECT)>0) and Duel.SelectYesNo(tp, aux.Stringid(id, 6)) then
				local tc=Duel.SelectMatchingCard(tp, s.mirrorfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
				if Duel.SendtoHand(tc, tp,REASON_EFFECT)>0 then
					Duel.ConfirmCards(1-tp, tc)
				end
			end
		end
		Duel.RegisterFlagEffect(tp,id+6,0,0,0)
	end
end








function s.orichalcosfield(c)
	return (c:IsCode(48179391) or c:IsCode(110000100) or c:IsCode(110000101))
end

function s.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	local tc=te:GetHandler()
	return p==tp and (loc&LOCATION_ONFIELD)~=0 and s.orichalcosfield(tc) and tc~=e:GetHandler()
end
