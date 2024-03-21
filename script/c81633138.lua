--Shackles of the Gravekeepers
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
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetTargetRange(0,LOCATION_GRAVE)
        e2:SetValue(s.value)
        Duel.RegisterEffect(e2,tp)

		--other passive duel effects go here    

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_CANNOT_TRIGGER)
        e8:SetTargetRange(LOCATION_HAND,0)
        e8:SetTarget(s.actfilter)
        Duel.RegisterEffect(e8, tp)
	end
	e:SetLabel(1)
end


function s.value(e,re,rp)
	return re and re:IsActiveType(TYPE_MONSTER)	and re:GetHandler():IsCode(63542003,99937011) and re:GetHandlerPlayer()==e:GetHandlerPlayer()
end

function s.discon(e)
	return Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()
end

function s.actfilter(e,c)
	return c:IsCode(25926710)
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 98715423)
	if g and #g>0 then
		for tc in g:Iter() do
			if tc:GetFlagEffect(id)==0 then
				tc:RegisterFlagEffect(id,0,0,0)
				local eff={tc:GetCardEffect()}
				for _,teh in ipairs(eff) do
					if teh:GetProperty()&EFFECT_FLAG_PLAYER_TARGET==EFFECT_FLAG_PLAYER_TARGET then
						teh:Reset()
					end
				end
		end
	end
    end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
