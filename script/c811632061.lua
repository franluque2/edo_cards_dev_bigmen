--Impatience is a Virtue
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

        local c=e:GetHandler()

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
        e1:SetCountLimit(1)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(s.operation)
    Duel.RegisterEffect(e2, tp)




	e:SetLabel(1)
    end
end

function s.notmarkedfilter(c)
    return c:IsMonster() and not c:HasFlagEffect(id)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.notmarkedfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 1)

        if tc:IsSummonableCard() then 
            local effs={tc:GetOwnEffects()}
            for _,eff in ipairs(effs) do
                if Effect.GetRange(eff)&LOCATION_MZONE==LOCATION_MZONE and Effect.GetType(eff)&EFFECT_TYPE_IGNITION==EFFECT_TYPE_IGNITION then
                    local neweff=eff:Clone()
                    neweff:SetRange(LOCATION_HAND)
                    neweff:SetType(EFFECT_TYPE_QUICK_O)
                    neweff:SetCode(EVENT_FREE_CHAIN)
                    neweff:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)

					if eff:IsHasProperty(EFFECT_FLAG_NO_TURN_RESET) then
						neweff:SetProperty(eff:GetProperty() & (~EFFECT_FLAG_NO_TURN_RESET))
					end
                    tc:RegisterEffect(neweff)
                end
            end
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
