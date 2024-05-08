--Mirror Image
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

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_DRAW)
		e2:SetCondition(s.drawcon)
		e2:SetOperation(s.drawop)
        e2:SetCountLimit(1)
		Duel.RegisterEffect(e2,tp)

		--give infinite hand size
		local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_HAND_LIMIT)
		e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e7:SetTargetRange(1,0)
		e7:SetValue(100)
		Duel.RegisterEffect(e7,tp)

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_DRAW_COUNT)
		e3:SetTargetRange(1,0)
		e3:SetValue(s.val)
		Duel.RegisterEffect(e3,tp)


		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_DRAW)
		e4:SetCondition(s.drawcon2)
		e4:SetOperation(s.drawop2)
        e4:SetCountLimit(1)
		Duel.RegisterEffect(e4,tp)




	end
	e:SetLabel(1)
end

function s.val(e)
	if Duel.IsExistingMatchingCard(s.fumadoorfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil) and kdr.IsQuestDone(e:GetHandlerPlayer()) then
		return 2
	else
		return 1
	end
end
local NEO_AQUA_MADOOR=49563947

function s.revspellfilter(c)
    return c:IsSpell() and not c:IsPublic()
end

function s.fumadoorfilter(c)
	return c:IsCode(NEO_AQUA_MADOOR) and c:IsFaceup()
end

function s.drawcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.fumadoorfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end
function s.drawop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,s.getpicture(tp))
	Duel.Draw(tp, 1, REASON_RULE)
end

function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.revspellfilter, tp, LOCATION_HAND, 0, 1, nil)
        and Duel.IsPlayerCanSpecialSummonMonster(tp,id+2,0,TYPES_TOKEN,0,0,7,RACE_SPELLCASTER,ATTRIBUTE_DARK,POS_FACEUP)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		Duel.Hint(HINT_CARD,tp,s.getpicture(tp))
		local torev=Duel.SelectMatchingCard(tp, s.revspellfilter, tp, LOCATION_HAND, 0, 1,99, false, nil)
		if torev then
			Duel.ConfirmCards(1-tp, torev)
			local token=Duel.CreateToken(tp, id+2)
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
				local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK)
			e3:SetValue(#torev*500)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e3)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_SET_DEFENSE)
			token:RegisterEffect(e4)

			Duel.SpecialSummonComplete()

			aux.DelayedOperation(token,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,0)

			end
			Duel.ShuffleHand(tp)
		end
	end
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end


function s.upgrade(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return end
	if kdr.IsQuestDone(ep) then return end
    kdr.CompleteQuest(ep,e:GetHandler(),e)
    e:GetHandler():Recreate(id+1)
    Duel.Hint(HINT_SKILL_REMOVE,ep,id)
    Duel.Hint(HINT_SKILL_FLIP,ep,(id+1)|(1<<32))
    Duel.Hint(HINT_SKILL,ep,id+1)
	
end

function s.getpicture(tp)
	if not (kdr.IsQuestDone(tp)) then
		return id
	else
		return id+1
	end
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

function s.remfromfieldfilter(c)
	return c:IsCode(id+2) and (c:IsAttackAbove(1500) or c:IsDefenseAbove(1500))
end

function s.spmadoorfilter(c,e,tp)
	return c:IsCode(NEO_AQUA_MADOOR) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false)
end

function s.remrelicfilter(c)
	return c:IsCode(id+2) and (c:IsAttackAbove(3000))
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 then return end
	--Boolean checks for the activation condition: b1, b2, b3, b4


	local b1=Duel.GetFlagEffect(tp,id+1)==0
		and Duel.IsExistingMatchingCard(s.remfromfieldfilter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.spmadoorfilter,tp,LOCATION_HAND,0,1,nil,e,tp)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
	and Duel.IsExistingMatchingCard(s.spmadoorfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
				and Duel.IsExistingMatchingCard(s.remrelicfilter, tp, LOCATION_MZONE, 0, 1, nil)




	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,s.getpicture(tp))

	local b1=Duel.GetFlagEffect(tp,id+1)==0
		and Duel.IsExistingMatchingCard(s.remfromfieldfilter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.spmadoorfilter,tp,LOCATION_HAND,0,1,nil,e,tp)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
	and Duel.IsExistingMatchingCard(s.spmadoorfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
				and Duel.IsExistingMatchingCard(s.remrelicfilter, tp, LOCATION_MZONE, 0, 1, nil)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
								  {b2,aux.Stringid(id,2)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, s.remfromfieldfilter, tp, LOCATION_MZONE, 0, 1,1, false, nil)
	if g then
		Duel.SendtoGrave(g, REASON_EFFECT)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp, s.spmadoorfilter, tp, LOCATION_HAND,0, 1,1,false,nil,e,tp)
	if tc then
		Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
		s.upgrade(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,s.getpicture(tp))
		if Duel.IsPlayerCanSpecialSummonMonster(tp,id+3,0,TYPES_TOKEN,1200,3000,6,RACE_SPELLCASTER,ATTRIBUTE_WATER,POS_FACEUP) then
			local token=Duel.CreateToken(tp,id+3)
			Duel.SpecialSummon(token, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
		end
	end
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, s.remrelicfilter, tp, LOCATION_MZONE, 0, 1,1, false, nil)
	if g then
		Duel.SendtoGrave(g, REASON_EFFECT)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp, s.spmadoorfilter, tp, LOCATION_HAND,0, 1,1,false,nil,e,tp)
	if tc then
		Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
	end
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end