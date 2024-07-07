--Who Counts the Spell Counters?
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
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        e2:SetCode(EVENT_CHAIN_SOLVING)
        e2:SetProperty(EFFECT_FLAG_DELAY)
        e2:SetOperation(s.spop)
        Duel.RegisterEffect(e2, tp)

        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e4:SetDescription(aux.Stringid(id,0))
        e4:SetCode(id)
        e4:SetTargetRange(1,0)
        Duel.RegisterEffect(e4,tp)

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e5:SetCode(EVENT_FREE_CHAIN)
        e5:SetCondition(s.flipcon2)
        e5:SetOperation(s.flipop2)
        Duel.RegisterEffect(e5,tp)
	end
	e:SetLabel(1)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		Duel.RegisterFlagEffect(tp, id, 0,0,0)

        local ce=Duel.IsPlayerAffectedByEffect(tp,id)
        if ce then
            local nce=ce:Clone()
            ce:Reset()
            nce:SetDescription(aux.Stringid(id,Duel.GetFlagEffect(tp, id)))
            Duel.RegisterEffect(nce,tp)
        end
	end
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end



function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCanAddCounter,COUNTER_SPELL,1),tp,LOCATION_ONFIELD,0,1,nil) and Duel.GetFlagEffect(tp, id-1)==0 and Duel.GetFlagEffect(tp, id)>0
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)

    local cg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter,COUNTER_SPELL,1),tp,LOCATION_ONFIELD,0,nil)
    Duel.BreakEffect()
    cg:Select(tp,1,1,nil):GetFirst():AddCounter(COUNTER_SPELL,Duel.GetFlagEffect(tp, id))



    Duel.ResetFlagEffect(tp, id)
    local ce=Duel.IsPlayerAffectedByEffect(tp,id)
    if ce then
		local nce=ce:Clone()
		ce:Reset()
		nce:SetDescription(aux.Stringid(id,Duel.GetFlagEffect(tp, id)))
		Duel.RegisterEffect(nce,tp)
    end

    Duel.RegisterFlagEffect(tp, id-1, RESET_PHASE+PHASE_END, 0,0)
end