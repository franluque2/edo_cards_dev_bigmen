--Conscription in Wrighting
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



--change this to change the locations where this acts
local LOCATIONS=LOCATION_ALL-LOCATION_OVERLAY

--add archetype setcode here
local ARCHETYPE=CARD_SKULL_SERVANT

--All Zombie monsters in your possession are also named skull servant
function s.archetypefilter(c)
  return c:IsRace(RACE_ZOMBIE)
end

function s.archetypefilter2(c)
    return c:IsCode(29155212)
end

function s.archetypefilter3(c)
    return c:IsCode(17601919)
end

function s.archetypefilter4(c)
    return c:IsOriginalCode(CARD_SKULL_SERVANT)
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


    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_ADD_CODE)
    e3:SetTargetRange(LOCATIONS,0)
    e3:SetTarget(aux.TargetBoolFunction(s.archetypefilter))
    e3:SetValue(ARCHETYPE)
    Duel.RegisterEffect(e3,tp)

    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_ADD_CODE)
    e4:SetTargetRange(LOCATIONS,0)
    e4:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
    e4:SetValue(36021814)
    Duel.RegisterEffect(e4,tp)

    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_ADD_CODE)
    e5:SetTargetRange(LOCATIONS,0)
    e5:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
    e5:SetValue(40991587)
    Duel.RegisterEffect(e5,tp)

    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_ADD_CODE)
    e6:SetTargetRange(LOCATION_ONFIELD,0)
    e6:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
    e6:SetValue(00062121)
    Duel.RegisterEffect(e6,tp)


	end
	e:SetLabel(1)
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(s.archetypefilter2, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.archetypefilter3, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e4=Effect.CreateEffect(e:GetHandler())
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(id+1)
				tc:RegisterEffect(e4)


			tc=g:GetNext()
		end
	end

    g=Duel.GetMatchingGroup(s.archetypefilter4, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e4=Effect.CreateEffect(e:GetHandler())
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(id+2)
				tc:RegisterEffect(e4)


			tc=g:GetNext()
		end
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
