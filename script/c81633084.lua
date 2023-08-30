--Underhanded Facility Tactics
--add archetype Template
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end



--change this to change the locations where this acts
local LOCATIONS=LOCATION_ALL-LOCATION_OVERLAY

--add archetype setcode here
local ARCHETYPE=0x1186

--add the conditions for the archetype swap here
function s.EARTHS(c)
  return c:IsAttribute(ATTRIBUTE_EARTH)
end

function s.IronChainDragon(c)
    return c:IsCode(19974580)
end

function s.Chains(c)
    return c:IsCode(33302407, 79707116, 511001387)
end

function s.IronChainCoil(c)
    return c:IsCode(53152590)
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
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATIONS,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(0x25)
        Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_RACE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e6:SetValue(RACE_WARRIOR)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_CODE)
        e7:SetTargetRange(LOCATIONS,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e7:SetValue(70902743)
        Duel.RegisterEffect(e7,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_CODE)
        e8:SetTargetRange(LOCATIONS,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e8:SetValue(50078509)
        Duel.RegisterEffect(e8,tp)

		local e9=Effect.CreateEffect(e:GetHandler())
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCountLimit(1)
		e9:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e9:SetCondition(s.revcon)
		e9:SetOperation(s.revop)
		Duel.RegisterEffect(e9,tp)

		local e11=Effect.CreateEffect(e:GetHandler())
		e11:SetType(EFFECT_TYPE_FIELD)
		e11:SetCode(EFFECT_SYNCHRO_LEVEL)
		e11:SetTargetRange(LOCATION_MZONE, 0)
		e11:SetTarget(function (_,c) return c:IsCode(53152590) end)
		e11:SetValue(s.slevel)
        Duel.RegisterEffect(e11,tp)
    

	end
	e:SetLabel(1)
end

function s.fuchainfilter(c)
return c:IsFaceup() and c:IsCode(33302407,79707116)
end

function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.fuchainfilter, tp, LOCATION_SZONE, 0, 1, nil) and Duel.IsExistingMatchingCard(Card.IsFacedown, tp, 0, LOCATION_SZONE, 1, nil)
end


function s.revop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.GetMatchingGroup(Card.IsFacedown, tp, 0, LOCATION_SZONE, nil)
	Duel.ConfirmCards(tp, g)
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

    local g=Duel.GetMatchingGroup(s.EARTHS, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.IronChainDragon, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.Chains, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+2)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.slevel(e,c)
	return 2*65536+c:GetLevel()
end

function s.sendtogravefilter(c)
	return c:IsOriginalSetCard(0x25) and c:IsAbleToGrave()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0  then return end
	local b1=Duel.GetFlagEffect(tp,id+1)==0
            and Duel.IsExistingMatchingCard(s.sendtogravefilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil)
			and Duel.IsExistingMatchingCard(Card.IsFacedown, tp, 0, LOCATION_SZONE, 1, nil)
			and Duel.IsPlayerCanDiscardDeck(1-tp, 1)
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local b1=Duel.GetFlagEffect(tp,id+1)==0
		and Duel.IsExistingMatchingCard(s.sendtogravefilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil)
		and Duel.IsExistingMatchingCard(Card.IsFacedown, tp, 0, LOCATION_SZONE, 1, nil)
		and Duel.IsPlayerCanDiscardDeck(1-tp, 1)

	--local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)})
	--op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	--if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	--end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local num=Duel.GetMatchingGroupCount(Card.IsFacedown, tp, 0, LOCATION_SZONE, nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp, s.sendtogravefilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1,1,false,nil)
	if tc and Duel.SendtoGrave(tc, REASON_RULE)	then
		Duel.DiscardDeck(1-tp, num, REASON_EFFECT)
	end

	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end