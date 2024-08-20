--Shackles of Reality
--Duel.LoadScript("big_aux.lua")
Duel.LoadScript("c420.lua")

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

       

        --local e5=Effect.CreateEffect(e:GetHandler())
        --e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        --e5:SetTargetRange(LOCATION_MZONE,0)
        --e5:SetTarget(function(_,c) return c:IsRace(RACE_ILLUSIONIST) end)
        --e5:SetLabelObject(e2)
        --Duel.RegisterEffect(e5,tp)

		local e11=Effect.CreateEffect(e:GetHandler())
		e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e11:SetCode(EVENT_CHAINING)
		e11:SetOperation(s.chainop)
		Duel.RegisterEffect(e11,tp)
        
	end
	e:SetLabel(1)
end

function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	Duel.SetChainLimit(s.chainlm)
end
function s.chainlm(e,rp,tp)
	return rp==tp and not e:GetHandler():IsRace(RACE_ILLUSION)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(Card.IsRace, tp, LOCATION_ALL, LOCATION_ALL, nil,RACE_ILLUSION)

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
	return re:GetHandler():IsRace(RACE_ILLUSION)
end

