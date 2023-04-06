--Tops Society
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

		--"Imperial Custom" you control cannot be destroyed by the effect of "Jester Queen".
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetTargetRange(LOCATION_ONFIELD,0)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetTarget(s.indestg)
		e2:SetValue(s.indval)
		Duel.RegisterEffect(e2,tp)


		--During your End Phase, you can return all monsters you control to the Hand.
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCountLimit(1)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCondition(s.bouncecon)
		e3:SetOperation(s.bounceop)
		Duel.RegisterEffect(e3,tp)

	end
	e:SetLabel(1)
end

function s.atohandfilter(c)
	return c:IsAbleToHand()
end

function s.indestg(e,c)
	return c:IsCode(09995766)
end

function s.bouncecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.atohandfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.bounceop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
		Duel.Hint(HINT_CARD,tp,id)
		local g=Duel.GetMatchingGroup(s.atohandfilter, tp, LOCATION_MZONE, 0, nil)
		if g then
			Duel.SendtoHand(g, tp, REASON_EFFECT)
		end
	end
end

function s.indval(e,re,rp)
	return re:GetOwner():IsCode(511000026)
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.setcustom(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

--At the start of the duel, set 1 "Imperial Custom" from outside the duel to your Spell/Trap Zone. It can be activated this turn.
function s.setcustom(e,tp,eg,ep,ev,re,r,rp)
	local icustom=Duel.CreateToken(tp, 09995766)
	Duel.SSet(tp, icustom)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	icustom:RegisterEffect(e2)
end

local MakeCheck=function(setcodes,archtable,extrafuncs)
	return function(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if extrafuncs then
			for _,func in pairs(extrafuncs) do
				if Card[func](c,sc,sumtype,playerid) then return true end
			end
		end
		if setcodes then
			for _,setcode in pairs(setcodes) do
				if c:IsSetCard(setcode,sc,sumtype,playerid) then return true end
			end
		end
		if archtable then
			if c:IsSummonCode(sc,sumtype,playerid,table.unpack(archtable)) then return true end
		end
		return false
	end
end



local set_traps={09995766}
Card.hasbeenset=MakeCheck(nil,set_traps)

function s.conttrapfiler(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable() and not c:hasbeenset()
end

function s.icustomfilter(c)
	return c:IsCode(09995766) and c:IsFaceup()
end

function s.cfilter(c,tp)
	return not c:IsPublic() and c:IsJester() and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c) and c:IsType(TYPE_MONSTER)
end
function s.thfilter(c,rc)
	return c:IsJester() and c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and not c:IsCode(rc:GetCode())
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

	--Once per turn, if you control "Imperial Customs", you can set 1 Continuous Trap from your Deck to your Spell/Trap Zone. It can be activated this turn.
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.icustomfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.conttrapfiler,tp,LOCATION_DECK,0,1,nil)

-- Once per turn, you can reveal 1 "Jester" monster in your hand, add 1 "Jester" monster from your Deck to your hand with a different name than the revealed card, then shuffle the revealed card into the Deck.
	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)


	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	--Once per turn, if you control "Imperial Customs", you can set 1 Continuous Trap from your Deck to your Spell/Trap Zone. It can be activated this turn.
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.icustomfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.conttrapfiler,tp,LOCATION_DECK,0,1,nil)

-- Once per turn, you can reveal 1 "Jester" monster in your hand, add 1 "Jester" monster from your Deck to your hand with a different name than the revealed card, then shuffle the revealed card into the Deck.
	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



--Set 1 Continuous Trap from your Deck to your Spell/Trap Zone. It can be activated this turn.
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp, s.conttrapfiler, tp, LOCATION_DECK, 0, 1,1,false,nil):GetFirst()
	if g then
		table.insert(set_traps,g:GetCode())
		Duel.SSet(tp, g)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:RegisterEffect(e2)

	end



	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


--reveal 1 "Jester" monster in your hand, add 1 "Jester" monster from your Deck to your hand with a different name than the revealed card, then shuffle the revealed card into the Deck.
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND, 0, 1,1,false,nil,tp)
	if g then
		Duel.ConfirmCards(1-tp, g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1,1,false,nil,g:GetFirst())
			if tc then
				Duel.SendtoHand(tc, tp, REASON_EFFECT)
				Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
			end
	end

	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
