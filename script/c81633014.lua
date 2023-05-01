--Conscription of the 8th Card Professor
--add archetype Template
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
local ARCHETYPE=0x1186

--White Horned Dragon
function s.archetypefilter(c)
  return c:IsCode(73891874)
end

--Dragonutes
function s.archetypefilter2(c)
    return c:IsCode(73891874, 84914462, 11125718)
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

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_ATTRIBUTE)
        e9:SetTargetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e9:SetValue(ATTRIBUTE_EARTH)
        Duel.RegisterEffect(e9,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_ADD_ATTRIBUTE)
        e10:SetTargetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0)
        e10:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e10:SetValue(ATTRIBUTE_WIND)
        Duel.RegisterEffect(e10,tp)

        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_ADD_ATTRIBUTE)
        e11:SetTargetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0)
        e11:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e11:SetValue(ATTRIBUTE_WATER)
        Duel.RegisterEffect(e11,tp)

        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_ADD_ATTRIBUTE)
        e12:SetTargetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0)
        e12:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e12:SetValue(ATTRIBUTE_FIRE)
        Duel.RegisterEffect(e12,tp)
    

	end
	e:SetLabel(1)
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

    local g=Duel.GetMatchingGroup(s.archetypefilter, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    local g=Duel.GetMatchingGroup(s.archetypefilter2, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e13=Effect.CreateEffect(e:GetHandler())
				e13:SetType(EFFECT_TYPE_SINGLE)
				e13:SetCode(id)
				tc:RegisterEffect(e13)


			tc=g:GetNext()
		end
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

