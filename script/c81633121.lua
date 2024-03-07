--Elite Professor Vintage strats
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



--change this to change the locations where this acts
local LOCATIONS=LOCATION_ALL-LOCATION_OVERLAY

--add archetype setcode here
local ARCHETYPE=0x1186

--add the conditions for the archetype swap here
function s.Gadgets(c)
  return c:IsSetCard(0x51)
end

function s.DupOffering(c)
  return c:IsCode(63995093, 76823930)
end




function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_CODE)
        e5:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(83104731)
        Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_SETCODE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e6:SetValue(0x7)
        Duel.RegisterEffect(e6,tp)

		local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e7:SetCode(EVENT_CHAINING)
		e7:SetCondition(s.sumcon)
		e7:SetOperation(s.sumop)
        e7:SetCountLimit(1)
		Duel.RegisterEffect(e7,tp)

		local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_SETCODE)
        e8:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e8:SetValue(0x7)
        Duel.RegisterEffect(e8,tp)
    

	end
	e:SetLabel(1)
end
local ANCIENT_GEAR_CARD=31557782
local ANCIENT_GEAR_STATUE=500000006

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsOriginalCode(ANCIENT_GEAR_STATUE)
end

function s.highlevelag(c)
	return c:IsLevelAbove(6) and c:IsSetCard(0x7)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD, tp, id)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(s.highlevelag))
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end



function s.markedfilter(c,e)
    return #c:IsHasEffect(e)>0
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(s.Gadgets, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    g=Duel.GetMatchingGroup(s.DupOffering, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+1)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.notpublicgear(c)
	return c:IsCode(ANCIENT_GEAR_CARD) and not c:IsPublic()
end

function s.notancientgear(c)
	return c:IsFaceup() and not c:IsCode(ANCIENT_GEAR_CARD)
end

function s.tributeancientgear(c)
	return c:IsFaceup() and c:IsCode(ANCIENT_GEAR_CARD) and c:IsReleasable()
end

function s.shufflemachinefilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsMonster() and c:IsAbleToDeck() and not c:IsCode(ANCIENT_GEAR_CARD)
end

function s.spsummonfilter(c,e,tp)
	return (c:IsCode(ANCIENT_GEAR_STATUE) or c:IsSetCard(0x51)) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false, POS_FACEUP)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.notancientgear,tp,LOCATION_MZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.notpublicgear,tp,LOCATION_HAND,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.tributeancientgear,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetMatchingGroupCount(s.shufflemachinefilter, tp, LOCATION_GRAVE, 0, nil)>2
			and Duel.GetFlagEffect(tp,id+5)==0
			and Duel.IsPlayerCanDraw(tp)

	local b3=Duel.GetFlagEffect(tp,id+3)==0
		and Duel.IsExistingMatchingCard(s.tributeancientgear,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFlagEffect(tp,id+5)==0
		and Duel.IsExistingMatchingCard(s.spsummonfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)

	local b4=Duel.GetFlagEffect(tp,id+4)==0
		and Duel.GetFlagEffect(tp,id+5)==0
		and Duel.IsExistingMatchingCard(s.tributeancientgear,tp,LOCATION_MZONE,0,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above
	local b1=Duel.GetFlagEffect(tp,id+1)==0
	and Duel.IsExistingMatchingCard(s.notancientgear,tp,LOCATION_MZONE,0,1,nil)
				and Duel.IsExistingMatchingCard(s.notpublicgear,tp,LOCATION_HAND,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
	and Duel.IsExistingMatchingCard(s.tributeancientgear,tp,LOCATION_MZONE,0,1,nil)
	and Duel.GetMatchingGroupCount(s.shufflemachinefilter, tp, LOCATION_GRAVE, 0, nil)>2
	and Duel.IsPlayerCanDraw(tp)
	and Duel.GetFlagEffect(tp,id+5)==0

	local b3=Duel.GetFlagEffect(tp,id+3)==0
	and Duel.IsExistingMatchingCard(s.tributeancientgear,tp,LOCATION_MZONE,0,1,nil)
	and Duel.IsExistingMatchingCard(s.spsummonfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
	and Duel.GetFlagEffect(tp,id+5)==0

	local b4=Duel.GetFlagEffect(tp,id+4)==0
	and Duel.IsExistingMatchingCard(s.tributeancientgear,tp,LOCATION_MZONE,0,1,nil)
	and Duel.GetFlagEffect(tp,id+5)==0

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,2)},
								  {b4,aux.Stringid(id,3)})
	op=op-1

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



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local gear=Duel.SelectMatchingCard(tp, s.notpublicgear, tp, LOCATION_HAND, 0, 1,1,false,nil)
	if gear then
		Duel.ConfirmCards(1-tp, gear)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
		local newcard=Duel.SelectMatchingCard(tp, s.notancientgear, tp, LOCATION_MZONE, 0, 1,1,false,nil)
		if newcard then
			local actualnewcard=newcard:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_ADD_CODE)
            e1:SetValue(ANCIENT_GEAR_CARD)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            actualnewcard:RegisterEffect(e1)
		end

	end

	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local gear=Duel.SelectMatchingCard(tp, s.tributeancientgear, tp, LOCATION_MZONE, 0, 1,1,false,nil)

	if gear and Duel.Release(gear, REASON_RULE) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
		local machines=Duel.SelectMatchingCard(tp, s.shufflemachinefilter, tp, LOCATION_GRAVE, 0, 3,3,false,nil)
		if Duel.SendtoDeck(machines, tp, SEQ_DECKSHUFFLE, REASON_RULE) then
			Duel.Draw(tp, 1, REASON_RULE)
		end

	end

	Duel.RegisterFlagEffect(tp,id+5,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local gear=Duel.SelectMatchingCard(tp, s.tributeancientgear, tp, LOCATION_MZONE, 0, 1,1,false,nil)

	if gear and Duel.Release(gear, REASON_RULE) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local gadget=Duel.SelectMatchingCard(tp, s.spsummonfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
		Duel.SpecialSummon(gadget, SUMMON_TYPE_SPECIAL, tp, tp, 0, 0, POS_FACEUP)
	end
	Duel.RegisterFlagEffect(tp,id+5,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)

	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end

function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	local gear=Duel.SelectMatchingCard(tp, s.tributeancientgear, tp, LOCATION_MZONE, 0, 1,1,false,nil)
	if gear then
		local geartochange=gear:GetFirst()
		local code=geartochange:GetCode()
		--"Gadget" monster, except this card's current name
		s.announce_filter={0x51,OPCODE_ISSETCARD,code,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND}
		local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(ac)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		geartochange:RegisterEffect(e1)
	
	end

	Duel.RegisterFlagEffect(tp,id+5,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)

	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
end
