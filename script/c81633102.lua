--Wandering Shackles of Calamity
Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)

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


        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_CANNOT_TRIGGER)
        e6:SetTargetRange(LOCATION_MZONE,0)
        e6:SetTarget(s.actfilter)
        Duel.RegisterEffect(e6, tp)

		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e5:SetCode(EVENT_REMOVE)
		e5:SetCondition(s.revcon)
		e5:SetOperation(s.revop)
		Duel.RegisterEffect(e5,tp)

	end
	e:SetLabel(1)
end

function s.actfilter(e,c)
	return c:IsCode(88581108)
end

function s.donebylithosagymfilter(c,re)
	local tc=re:GetHandler()
	return tc and tc:IsCode(30539496)
end

function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.donebylithosagymfilter,1,nil,re)
end

function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.donebylithosagymfilter, nil, re)
	Duel.Hint(HINT_CARD, tp, id)
	Duel.SendtoDeck(g, g:GetFirst():GetOwner(), SEQ_DECKSHUFFLE, REASON_RULE)
end









function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	local g=Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_ALL, LOCATION_ALL, nil,TYPE_SYNCHRO)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do

			local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BATTLE_INDES)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(s.batval)
		tc:RegisterEffect(e1)

            tc=g:GetNext()
        end
    end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.batval(e,re,c)
	return re:GetHandler():IsType(TYPE_SYNCHRO)
end