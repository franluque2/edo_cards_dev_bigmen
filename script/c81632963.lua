--Corrupted Gang Leader
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

       
        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DESTROY_REPLACE)
		e2:SetTarget(s.desreptg)
		e2:SetValue(s.desrepval)
		e2:SetOperation(s.desrepop)
		Duel.RegisterEffect(e2,tp)


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

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EVENT_CHANGE_POS)
        e3:SetCountLimit(1,id)
        e3:SetCondition(s.atkcon)
        e3:SetOperation(s.atkop)
        Duel.RegisterEffect(e3,tp)
		

	end
	e:SetLabel(1)
end

function s.chanfilter(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return not c:IsStatus(STATUS_CONTINUOUS_POS) and ((np<3 and pp>3) or (pp<3 and np>3))
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.chanfilter,1,nil) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15914410,41309150), tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.chanfilter, nil)
	Duel.Hint(HINT_CARD,tp,id)
    local tc=eg:GetFirst()
    while tc do
        if tc:GetControler()==tp then
            local val=1000
        else
            local val=-1000
        end

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
    end
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
	if tc:IsSummonType(SUMMON_TYPE_SPECIAL) and tc:IsCode(TOKEN_ENGINE) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		Duel.ChangePosition(eg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end


function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x1073) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e,tp)
	return c:IsCode(47660516) and c:IsAbleToRemove()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.cfilter(c)
	return c:IsCode(47660516) and c:IsAbleToRemove()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sg=g:FilterSelect(tp,s.desfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		Duel.HintSelection(sg)
		return true
	else return false end
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc, POS_FACEUP, REASON_EFFECT+REASON_REPLACE)
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


end



function s.angineerfilter(c)
    return c:IsCode(15914410) and c:GetOverlayCount()==0
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.angineerfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.GetLocationCount(tp, LOCATION_SZONE)>0


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above


	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.angineerfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

--effect selector
	local op=Duel.SelectEffect(tp, {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	--if op==0 then
	--	s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	--elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	--end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    local bforce=Duel.CreateToken(tp, 47660516)
    Duel.SSet(tp, bforce)

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
