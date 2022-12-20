--Revenge of Dyna Dude
--Duel.LoadScript("big_aux.lua")

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

        local c=e:GetHandler()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCondition(s.sscon)
		e2:SetOperation(s.ssop)
		Duel.RegisterEffect(e2,tp)


		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_ADD_CODE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(function(_,c)  return c:IsType(TYPE_TOKEN) end)
		e3:SetValue(511000882)
		Duel.RegisterEffect(e3,tp)

		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_ADD_CODE)
		e4:SetTargetRange(LOCATION_MZONE,0)
		e4:SetTarget(function(_,c)  return c:IsType(TYPE_TOKEN) end)
		e4:SetValue(140000085)
		Duel.RegisterEffect(e4,tp)


		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
		e5:SetCode(EFFECT_ADD_ATTRIBUTE)
		e5:SetTarget(s.changeatttypefilter)
		e5:SetValue(ATTRIBUTE_DARK)
		Duel.RegisterEffect(e5, tp)

		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
		e6:SetCode(EFFECT_ADD_RACE)
		e6:SetTarget(s.changeatttypefilter)
		e6:SetValue(RACE_MACHINE)
		Duel.RegisterEffect(e6, tp)

		local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e7:SetTargetRange(LOCATION_MZONE,0)
		e7:SetTarget(aux.TargetBoolFunction(s.dmachinefilter,tp))
		e7:SetValue(s.indval)
		Duel.RegisterEffect(e7,tp)


	end
	e:SetLabel(1)
end

function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end


function s.tokenfilter(c)
	return c:IsType(TYPE_TOKEN) and c:IsFaceup()
end

function s.dmachinefilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.tokenfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.changeatttypefilter(e,c)
	return c:IsCode(67532912,79853073,75559356,140000083) and c:IsFaceup()
end


function s.toysoldierfilter(c,e,tp)
	return c:IsCode(67532912,79853073,75559356) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetTurnPlayer()==tp and not (Duel.GetFlagEffect(tp,id+3)>0) then return end

	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.toysoldierfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.GetLocationCount(tp, LOCATION_MZONE)>0


	return Duel.GetTurnPlayer()==tp and (b1)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)	
		local g=Duel.GetMatchingGroup(s.toysoldierfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
        if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.Hint(HINT_CARD,tp,id)
            local tc=g:Select(tp, 1, 1,nil)
            if tc then
                Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
            end
        end
    Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)

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

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

    local seal=Duel.CreateToken(tp, 48179391)
	Duel.ActivateFieldSpell(seal,e,tp,eg,ep,ev,re,r,rp)

end

function s.skyunionfilter(c)
    return c:IsCode(140000082) and c:IsSSetable()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+4)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,67532912),tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,79853073),tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,75559356),tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,3,nil,TYPE_TOKEN)
            and Duel.IsExistingMatchingCard(s.skyunionfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
            and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

    local b3=Duel.GetFlagEffect(tp,id+4)==0
            and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,511000265),tp,LOCATION_ONFIELD,0,1,nil)



--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

    local b1=Duel.GetFlagEffect(tp,id+1)==0
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,67532912),tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,79853073),tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,75559356),tp,LOCATION_ONFIELD,0,1,nil)
                    and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

    local b2=Duel.GetFlagEffect(tp,id+2)==0
        and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,3,nil,TYPE_TOKEN)
        and Duel.IsExistingMatchingCard(s.skyunionfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

    local b3=Duel.GetFlagEffect(tp,id+4)==0
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,511000265),tp,LOCATION_ONFIELD,0,1,nil)


--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
								  {b2,aux.Stringid(id,2)},
								  {b3,aux.Stringid(id,3)})
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
    local rev=Duel.CreateToken(tp, 511001897)
			Duel.SSet(tp, rev)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			rev:RegisterEffect(e2)

	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp, s.skyunionfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1,1,nil)
    if tc then
        Duel.SSet(tp, tc)
    end
	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(ATTRIBUTE_FIRE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(s.efilter)
	Duel.RegisterEffect(e2,tp)

    local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTargetRange(1,0)
	Duel.RegisterEffect(e3,tp)


	--sets the opd
	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
end

function s.efilter(e,re)
	return re:GetOwner():IsCode(511001894)
end