--Chosen by the Crimson Duel Dragon
Duel.LoadScript ("c420.lua")
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
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCondition(s.sendcon)
		e2:SetOperation(s.sendop)
		Duel.RegisterEffect(e2,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_ADD_SETCODE)
		e3:SetTargetRange(LOCATION_GRAVE+LOCATION_MZONE,0)
		e3:SetTarget(function (_, tc) return tc:IsType(TYPE_MONSTER) and tc:IsRace(RACE_FIEND) and tc:IsAttribute(ATTRIBUTE_DARK) end)
		e3:SetValue(0x52f)
		Duel.RegisterEffect(e3,tp)

        local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_ADD_SETCODE)
		e4:SetTargetRange(LOCATION_GRAVE,0)
		e4:SetTarget(function (_, tc) return tc:IsType(TYPE_MONSTER) and tc:IsType(TYPE_TUNER) end)
		e4:SetValue(0x57)
		Duel.RegisterEffect(e4,tp)


	end
	e:SetLabel(1)
end


function s.backjackfilter(c)
	return c:IsCode(60990740) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetTurnPlayer()==tp and not (Duel.GetFlagEffect(tp,id+3)>0) then return end

	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.backjackfilter,tp,LOCATION_DECK,0,1,nil)


	return Duel.GetTurnPlayer()==tp and (b1)
end

function s.sendop(e,tp,eg,ep,ev,re,r,rp)	
		local g=Duel.GetMatchingGroup(s.backjackfilter,tp,LOCATION_DECK,0,nil)
        if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.Hint(HINT_CARD,tp,id)
            local tc=g:GetFirst()
            if tc then
                Duel.SendtoGrave(tc, REASON_EFFECT)
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

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

    local backjack=Duel.CreateToken(tp, 60990740)
	Duel.SendtoGrave(backjack, REASON_RULE)

end

function s.setcardfilter(c)
    return ((c:IsType(TYPE_SPELL) and c:IsType(TYPE_EQUIP)) or c:IsCode(10723472) or (c:IsChampion() and c:IsType(TYPE_TRAP))) and c:IsSSetable()
end

function s.monsterfilter(c)
	return c:IsFaceup() and c:HasLevel()
end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
        and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

	




--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
    and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)


--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

    local tc=Duel.SelectMatchingCard(tp,s.monsterfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			if tc then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
				local lvl=Duel.AnnounceLevel(tp,1,7)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lvl)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end