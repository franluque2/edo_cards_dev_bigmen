--Tunnelling Worms of Hanoi
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

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(s.repcon)
		e2:SetOperation(s.repop)
		Duel.RegisterEffect(e2,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_ADD_SETCODE)
        e3:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e3:SetTarget(aux.TargetBoolFunction(s.MotorWormFilter))
        e3:SetValue(0x172)
        Duel.RegisterEffect(e3,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_CANNOT_TRIGGER)
        e7:SetTargetRange(LOCATION_HAND,0)
        e7:SetCondition(s.discon)
        e7:SetTarget(s.actfilter)
        Duel.RegisterEffect(e7, tp)

		--other passive duel effects go here

		--uncomment (remove the --) the line below to make it a rush skill
		--bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)


	end
	e:SetLabel(1)
end

function s.validreplacefilter(c,e)
    return c:IsType(TYPE_TOKEN) and (not c:IsCode(511009659)) and c:GetOwner() ==e:GetHandlerPlayer()
end

function s.WormHoleSetFilter(c)
    return c:IsCode(511009660) and c:IsSSetable()
end

function s.WormTokenDestroyFilter(c)
    return c:IsCode(511009659) and c:IsDestructable()
end

function s.MotorWormFilter(c)
    return c:IsCode(511009659, 511009658, 511009661, 511009660, 511009662, 511009663, 511106006)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.discon(e)
	return Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()
end

function s.actfilter(e,c)
	return c:IsCode(65430555)
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.validreplacefilter, 1, nil, e)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.Hint(HINT_CARD,tp,id)

    local tc=eg:GetFirst()
    while tc do
        if s.validreplacefilter(tc, e) then
            --Debug.Message(levelcards[level][Duel.GetRandomNumber(1,#levelcards[level])])
			tc:Recreate(511009659,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
            --tc:RegisterFlagEffect(id, RESETS_STANDARD, 0, 0)
        end
        
        tc=eg:GetNext()
    end

end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
	local Wormhole=Duel.CreateToken(tp,81632498)
			Duel.SSet(tp,Wormhole)

end

function s.fuwmdeffilter(c)
	return c:IsCode(511009660) and c:IsFaceup()
end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.WormHoleSetFilter,tp,LOCATION_GRAVE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.WormTokenDestroyFilter,tp,LOCATION_ONFIELD,0,1,nil)
                        and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
						and not Duel.IsExistingMatchingCard(s.fuwmdeffilter, tp, LOCATION_ONFIELD, 0, 1, nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
and Duel.IsExistingMatchingCard(s.WormHoleSetFilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.WormTokenDestroyFilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
local token=Duel.SelectMatchingCard(tp, s.WormTokenDestroyFilter, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
if token then
    local Defense=Duel.SelectMatchingCard(tp, s.WormHoleSetFilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if Defense and Duel.Destroy(token, REASON_RULE) then
        Duel.SSet(tp, Defense)
    end
end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end

