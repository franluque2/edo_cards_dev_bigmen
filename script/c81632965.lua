--KakoKakoMaguMagu
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
		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
		e5:SetCode(EFFECT_ADD_ATTRIBUTE)
		e5:SetTarget(s.chtg1)
		e5:SetValue(ATTRIBUTE_EARTH)
		Duel.RegisterEffect(e5, tp)

        local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
		e6:SetCode(EFFECT_ADD_ATTRIBUTE)
		e6:SetTarget(s.chtg2)
		e6:SetValue(ATTRIBUTE_FIRE)
		Duel.RegisterEffect(e6, tp)

        local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetTargetRange(LOCATION_GRAVE,0)
		e7:SetCode(EFFECT_ADD_TYPE)
		e7:SetTarget(s.chtg3)
		e7:SetValue(TYPE_NORMAL)
		Duel.RegisterEffect(e7, tp)


	end
	e:SetLabel(1)
end

function s.chtg1(e,c)
	return c:IsOriginalAttribute(ATTRIBUTE_FIRE)
end

function s.chtg2(e,c)
	return c:IsOriginalAttribute(ATTRIBUTE_EARTH)
end

function s.chtg3(e,c)
	return c:IsOriginalRace(RACE_PYRO)
end







function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.magmassagefilter(c)
    return c:IsFaceup() and c:IsCode(160004036)
end

function s.atohandfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsAbleToHand()
end

function s.changelvlfilter(c)
    return c:IsFaceup() and c:HasLevel()
end

function s.magmaxfilter(c)
    return c:IsFaceup() and c:IsCode(160004037)
end

function s.revcardfilter(c)
    return c:IsType(TYPE_MONSTER) and c:HasLevel() and not c:IsPublic()
end

function s.swapposfilter(c)
    return c:IsPosition(POS_FACEUP_ATTACK) and c:HasLevel() and c:IsCanChangePosition()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.magmassagefilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.changelvlfilter,tp,LOCATION_MZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.atohandfilter,tp,LOCATION_GRAVE,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
        and Duel.IsExistingMatchingCard(s.magmaxfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.revcardfilter,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.swapposfilter,tp,0,LOCATION_MZONE,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

    local b1=Duel.GetFlagEffect(tp,id+1)==0
    and Duel.IsExistingMatchingCard(s.magmassagefilter,tp,LOCATION_ONFIELD,0,1,nil)
    and Duel.IsExistingMatchingCard(s.changelvlfilter,tp,LOCATION_MZONE,0,1,nil)
                and Duel.IsExistingMatchingCard(s.atohandfilter,tp,LOCATION_GRAVE,0,1,nil)

    local b2=Duel.GetFlagEffect(tp,id+2)==0
    and Duel.IsExistingMatchingCard(s.magmaxfilter,tp,LOCATION_ONFIELD,0,1,nil)
    and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
    and Duel.IsExistingMatchingCard(s.revcardfilter,tp,LOCATION_HAND,0,1,nil)
    and Duel.IsExistingMatchingCard(s.swapposfilter,tp,0,LOCATION_MZONE,1,nil)

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



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local target=Duel.SelectMatchingCard(tp, s.changelvlfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil)
    if target then
        local tg=target:GetFirst()

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		tg:RegisterEffect(e1)

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local cards=Duel.SelectMatchingCard(tp, s.atohandfilter, tp, LOCATION_GRAVE, 0, 1,4,false,nil)
        if cards then
            Duel.SendtoHand(cards, tp, REASON_EFFECT)

            Duel.ConfirmCards(1-tp,cards)
		local tc=cards:GetFirst()
        local c=e:GetHandler()
		while tc do
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_SUMMON)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
			e2:SetReset(RESET_EVENT+0x07c0000)
			tc:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_SPSUMMON_CONDITION)
			e3:SetReset(RESET_EVENT+0x0f80000)
			tc:RegisterEffect(e3)
			tc=cards:GetNext()
		end
        end

    end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local card=Duel.SelectMatchingCard(tp, s.revcardfilter, tp, LOCATION_HAND, 0, 1, 1, false, nil):GetFirst()
    if card then
        Duel.ConfirmCards(1-tp, card)
        local availabletgs=Duel.GetMatchingGroup(s.swapposfilter, tp, 0, LOCATION_MZONE, nil)
        local g=Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACK)
        local targets=availabletgs:Select(tp, 1, g, false,nil)
        if targets then
            Duel.ChangePosition(targets, POS_FACEUP_DEFENSE)

            local tc=targets:GetFirst()
            while tc do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CHANGE_LEVEL)
                e1:SetValue(card:Level())
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                tc=cards:GetNext()
            end
        end
    end


	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
