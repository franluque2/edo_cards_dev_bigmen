--Pack of Nightmares

--Skill Template
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

		--other passive duel effects go here

		--uncomment (remove the --) the line below to make it a rush skill
		--bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)


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

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(ep,id,0,0,0)
end

-- At the start of the duel, place 2 "Plague Wolf" in your GY from outside the duel, then activate 1 "Edge of Darkness" from outside the duel.
function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
	local token1=Duel.CreateToken(tp, 55696885)
	local token2=Duel.CreateToken(tp, 55696885)
	Duel.SendtoGrave(token1, REASON_RULE)
	Duel.SendtoGrave(token2, REASON_RULE)

	local edgeofdarkness=Duel.CreateToken(tp, 511310023)
	Duel.ActivateFieldSpell(edgeofdarkness,e,tp,eg,ep,ev,re,r,rp)
end


function s.singlemonsterfilter(c,code)
	return c:IsCode(code) and c:IsFaceup()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

	local g=Duel.GetMatchingGroup(s.singlemonsterfilter, tp, LOCATION_ONFIELD, 0, nil, 55696885)
	local g2=Duel.GetMatchingGroup(s.singlemonsterfilter, tp, LOCATION_ONFIELD, 0, nil, 71200730)

--do bx for the conditions for each effect, and at the end add them to the return

--Once per turn, if you control exactly 1 "Plague Wolf" you can Special Summon 2 "Plague Wolf" from outside the duel in Attack Position,
-- then you can set 1 "Surrounded by Fallen Wolves" from your Deck to your Spell/Trap Zone. It can be activated this turn.
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and #g==1 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1
			and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)

--Once per turn, if you control exactly 1 "Despair from the Dark", you can Special Summon 2 "Despair from the Dark" from outside the duel in Attack Position.
	local b2=Duel.GetFlagEffect(tp,id+2)==0
		and #g2==1 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1
		and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)



--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local g=Duel.GetMatchingGroup(s.singlemonsterfilter, tp, LOCATION_ONFIELD, 0, nil, 55696885)
local g2=Duel.GetMatchingGroup(s.singlemonsterfilter, tp, LOCATION_ONFIELD, 0, nil, 71200730)

--do bx for the conditions for each effect, and at the end add them to the return

--Once per turn, if you control exactly 1 "Plague Wolf" you can Special Summon 2 "Plague Wolf" from outside the duel in Attack Position,
-- then you can set 1 "Surrounded by Fallen Wolves" from your Deck to your Spell/Trap Zone. It can be activated this turn.
local b1=Duel.GetFlagEffect(tp,id+1)==0
		and #g==1 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1
		and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)


--Once per turn, if you control exactly 1 "Despair from the Dark", you can Special Summon 2 "Despair from the Dark" from outside the duel in Attack Position.
local b2=Duel.GetFlagEffect(tp,id+2)==0
	and #g2==1 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1
	and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)


--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.surroundedfilter(c)
	return c:IsCode(511310024) and c:IsSSetable()
end


function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local token1=Duel.CreateToken(tp, 55696885)
	local token2=Duel.CreateToken(tp, 55696885)

	local group=Group.CreateGroup()
	group=group:AddCard(token1)
	group=group:AddCard(token2)

	Duel.SpecialSummon(group, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP_ATTACK)

	if Duel.IsExistingMatchingCard(s.surroundedfilter, tp, LOCATION_DECK, 0, 1,nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
		local surrounded=Duel.GetFirstMatchingCard(s.surroundedfilter, tp, LOCATION_DECK, 0, nil)
		if surrounded then
			Duel.SSet(tp, surrounded)

			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			surrounded:RegisterEffect(e1)

		end
	end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

	local token1=Duel.CreateToken(tp, 71200730)
	local token2=Duel.CreateToken(tp, 71200730)

	local group=Group.CreateGroup()
	group=group:AddCard(token1)
	group=group:AddCard(token2)

	Duel.SpecialSummon(group, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP_ATTACK)

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
