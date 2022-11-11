--Master Baiter
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
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e3:SetCountLimit(1)
		e3:SetCondition(s.spcon)
		e3:SetOperation(s.spop)
		Duel.RegisterEffect(e3,tp)
	end
	e:SetLabel(1)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(id,tp)~=0 and Duel.IsTurnPlayer(1-tp) and Duel.GetMatchingGroupCount(aux.True, tp, LOCATION_MZONE, 0, nil)==0
		and Duel.IsExistingMatchingCard(s.lurephantomfilter, tp, LOCATION_GRAVE+LOCATION_HAND, 0, 1, nil,e,tp)
end

--Once per turn, at the start of your Opponent's Battle Phase, if you control no monsters, you can Special Summon 1 "Lure Phantom" from your Hand or GY.

function s.lurephantomfilter(c,e,tp)
	return c:IsCode(511001382) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		 local tc=Duel.SelectMatchingCard(tp, s.lurephantomfilter, tp, LOCATION_GRAVE+LOCATION_HAND, 0, 1, 1,false,nil,e,tp)
		 if tc then
			 Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--
-- function s.retop(e,tp,eg,ep,ev,re,r,rp)
-- 	Duel.ReturnToField(e:GetLabelObject())
-- end


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



local set_cards={12312}
Card.hasbeenset=MakeCheck(nil,set_cards)

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.set_spain(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
end

function s.set_spain(e,tp,eg,ep,ev,re,r,rp)
	local spain=Duel.CreateToken(tp,81632123)
	Duel.SSet(tp, spain)
end

function s.blasthoundfilter(c)
	return c:IsCode(511001381) and c:IsFaceup()
end

function s.subspainfilter(c)
	return c:IsCode(511004327) and c:IsFaceup()
end

function s.tgfilter(c)
	return (Card.ListsCode(c,511004336) or c:IsCode(511004337) or c:IsCode(511004339) or c:IsCode(511004327) or c:IsCode(511004336) or c:IsCode(511004328)) and
	c:IsType(TYPE_SPELL) and c:IsSSetable() and not c:hasbeenset()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 then return end
	--Boolean checks for the activation condition: b1, b2

	--Once per turn, if you control "Substitute Pain", you can set 1 Spell that lists Prey Counter in it's text from your Deck to your Spell/Trap Zone.
	local b1=Duel.GetFlagEffect(ep,id+1)==0
			and Duel.IsExistingMatchingCard(s.subspainfilter,tp,LOCATION_SZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.GetLocationCount(tp, LOCATION_SZONE)

	--Once per turn, you can target 1 "Infernal Blasthound" you control, this turn, it gains 200 ATK for each Prey Counter on the field and it can attack your opponent directly.
	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(s.blasthoundfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 0x1107)>0



	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	--Once per turn, if you control "Substitute Pain", you can set 1 Spell that lists Prey Counter in it's text from your Deck to your Spell/Trap Zone.
	local b1=Duel.GetFlagEffect(ep,id+1)==0
			and Duel.IsExistingMatchingCard(s.subspainfilter,tp,LOCATION_SZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.GetLocationCount(tp, LOCATION_SZONE)

	--Once per turn, you can target 1 "Infernal Blasthound" you control, this turn,
	-- it gains 200 ATK for each Prey Counter on the field and it can attack your opponent directly.
	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(s.blasthoundfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 0x1107)>0


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1,false,nil)
	if g then
		Duel.SSet(tp, g)
		table.insert(set_cards,g:GetFirst():GetCode())
	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp, s.blasthoundfilter, tp, LOCATION_MZONE, 0, 1, 1,false,nil):GetFirst()
	if g then
		local atk=Duel.GetCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 0x1107)

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(atk*200)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:RegisterEffect(e2)

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:RegisterEffect(e1)
	end
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
