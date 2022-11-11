--Extreme Motor Oil
Duel.LoadScript("c420.lua")
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
		-- e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
		-- e3:SetCountLimit(1)
		-- e3:SetCondition(s.spcon)
		-- e3:SetOperation(s.spop)
		-- Duel.RegisterEffect(e3,tp)

		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_SPSUMMON_SUCCESS)
		e8:SetOperation(s.enginetokenchange)
		Duel.RegisterEffect(e8,tp)

		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetTargetRange(LOCATION_MZONE,0)
		e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e5:SetTarget(s.tg)
		e5:SetValue(ATTRIBUTE_DARK)
		Duel.RegisterEffect(e5, tp)



	end
	e:SetLabel(1)
end

function s.tg(e,c)
	if not c:IsCode(TOKEN_ENGINE) then return false end
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff
		if c:IsLocation(LOCATION_MZONE) then
			eff={Duel.GetPlayerEffect(c:GetControler(),EFFECT_NECRO_VALLEY)}
		end
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return true
end

function s.enginetokenchange(e,tp,eg,ev,ep,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSummonType(SUMMON_TYPE_SPECIAL) and tc:IsCode(TOKEN_ENGINE) and Duel.SelectYesNo(tp, aux.Stringid(id, 7)) then
		Duel.ChangePosition(eg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end

-- function s.summonablemon(c)
-- 	return c:IsLevelAbove(5) and c:IsSummonable(true, nil)
-- end
--
--
-- function s.spcon(e,tp,eg,ep,ev,re,r,rp)
-- 	return Duel.GetFlagEffect(id,tp)~=0 and Duel.IsExistingMatchingCard(s.summonablemon, tp, LOCATION_HAND, 0, 1, nil)
-- end
--
-- --Once per turn, at the start of your Opponent's Battle Phase, you can banish 1 monster you control. Return that monster to your field during the End Phase.
--
--
-- function s.spop(e,tp,eg,ep,ev,re,r,rp)
-- 	if Duel.SelectYesNo(tp, aux.Stringid(id, 5)) then
-- 		Duel.Hint(HINT_CARD,tp,id)
-- 		local tc=Duel.SelectMatchingCard(tp, s.summonablemon, tp, LOCATION_HAND, 0, 1,1,false,nil):GetFirst()
-- 		if tc then
-- 			Duel.Summon(tp, tc, true, nil)
-- 		end
--
-- 	end
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



local added_cards={12312}
Card.hasbeenadded=MakeCheck(nil,added_cards)



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
end


function s.sumfilter(c,e,tp,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsCode(code)
end

function s.sendfilter(c,code)
	return c:IsCode(code) and c:IsAbleToGrave() and c:IsFaceup()
end

function s.motordiscardfilter(c)
	return c:IsMotor() and c:IsType(TYPE_MONSTER) and c:IsDiscardable(REASON_COST)
end

function s.motorbackrowfilter(c)
	return (c:IsCode(511002411) or c:IsCode(511002410) or c:IsCode(511002409)) and c:IsAbleToHand() and not c:hasbeenadded()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+3)>0  then return end
	--Boolean checks for the activation condition: b1, b2
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and (( Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil,78394032)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,511002408))
			or (Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil,511002408)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,77672444))
			or (Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil,77672444)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,82556058)))
	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.motordiscardfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.motorbackrowfilter,tp,LOCATION_DECK,0,1,nil)

	local b3=Duel.GetFlagEffect(tp, id+3)==0
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ONFIELD, 0, 1, nil, 57793869)
		and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and (( Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil,78394032)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,511002408))
			or (Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil,511002408)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,77672444))
			or (Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil,77672444)
						and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,82556058)))
	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.motordiscardfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.motorbackrowfilter,tp,LOCATION_DECK,0,1,nil)

	local b3=Duel.GetFlagEffect(tp, id+3)==0
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ONFIELD, 0, 1, nil, 57793869)
		and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
								  {b2,aux.Stringid(id,0)},
									{b3, aux.Stringid(id, 6)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)

	local b1=Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil,78394032)
				and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,511002408)

	local b2=Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil,511002408)
				and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,77672444)

	local b3=Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_ONFIELD,0,1,nil,77672444)
				and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,82556058)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)},
													  {b2,aux.Stringid(id,3)},
														{b3,aux.Stringid(id,4)})
						op=op-1

	if op==0 then
		local g=Duel.SelectMatchingCard(tp, s.sendfilter, tp, LOCATION_ONFIELD, 0, 1,1,false,nil,78394032)
		if Duel.SendtoGrave(g, REASON_EFFECT) then
			local tc=Duel.SelectMatchingCard(tp,s.sumfilter, tp, LOCATION_DECK+LOCATION_HAND, 0, 1,1,false,nil,e,tp,511002408)
			if #tc>0 then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif op==1 then

		local g=Duel.SelectMatchingCard(tp, s.sendfilter, tp, LOCATION_ONFIELD, 0, 1,1,false,nil,511002408)
		if Duel.SendtoGrave(g, REASON_EFFECT) then
			local tc=Duel.SelectMatchingCard(tp,s.sumfilter, tp, LOCATION_DECK+LOCATION_HAND, 0, 1,1,false,nil,e,tp,77672444)
			if #tc>0 then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end

	elseif op==2 then

		local g=Duel.SelectMatchingCard(tp, s.sendfilter, tp, LOCATION_ONFIELD, 0, 1,1,false,nil,77672444)
		if Duel.SendtoGrave(g, REASON_EFFECT) then
			local tc=Duel.SelectMatchingCard(tp,s.sumfilter, tp, LOCATION_DECK+LOCATION_HAND, 0, 1,1,false,nil,e,tp,82556058)
			if #tc>0 then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end

	end

end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
	-- local g=Duel.SelectMatchingCard(tp, s.motordiscardfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
	if Duel.DiscardHand(tp, s.motordiscardfilter, 1,1, REASON_COST, nil) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp, s.motorbackrowfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
		if #tc>0 then
			Duel.SendtoHand(tc, tp,REASON_EFFECT)
			table.insert(added_cards,tc:GetFirst():GetCode())

		end
	end

	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	local devo=Duel.CreateToken(tp, 07373632)
	Duel.SSet(tp, devo)
	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end
