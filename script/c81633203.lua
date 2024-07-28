--Powers of the Arclight Crest
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
		e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_ADD_CODE)
        e2:SetValue(60316373)
        e2:SetTargetRange(LOCATION_GRAVE, 0)
        e2:SetTarget(function (_,c ) return c:IsOriginalSetCard(0x76) end)
        Duel.RegisterEffect(e2,tp)


	end
	e:SetLabel(1)
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


function s.nonxyzfilter(c)
    return c:IsFaceup() and not c:IsType(TYPE_XYZ)
end

function s.notsamenamefilter(c, cardid)
    return c:IsFaceup() and not c:IsCode(cardid)
end

function s.nonuniquecardfilter(c)
    return c:IsFaceup() and Duel.IsExistingMatchingCard(s.notsamenamefilter, c:GetControler(), LOCATION_MZONE, 0, 1, c, c:GetCode())
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	--Boolean checks for the activation condition: b1, b2

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.nonxyzfilter,tp,0,LOCATION_MZONE,1,nil)

	local b2=false and Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.nonuniquecardfilter,tp,0,LOCATION_MZONE,1,nil)


	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.nonxyzfilter,tp,0,LOCATION_MZONE,1,nil)

	local b2=false and Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.nonuniquecardfilter,tp,0,LOCATION_MZONE,1,nil)
--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
								  {b2,aux.Stringid(id,2)})

	if op==1 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc=Duel.SelectMatchingCard(tp, s.nonxyzfilter, tp, 0, LOCATION_MZONE, 1,1,false,nil)
    if tc then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetCode(EFFECT_ADD_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(TYPE_XYZ)
        tc:GetFirst():RegisterEffect(e1)
    end


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc=Duel.SelectMatchingCard(tp, s.nonuniquecardfilter, tp, 0, LOCATION_MZONE, 1,1,false,nil):GetFirst()
    if tc then
        local g=Duel.SelectMatchingCard(tp, s.notsamenamefilter, tp, 0, LOCATION_MZONE, 1,2,false,nil, tc:GetCode())
        for card in g:Iter() do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetValue(tc:GetCode())
            card:RegisterEffect(e1)
    
        end
    end


	
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
