--Future Conscription of the Law
--add archetype Template
Duel.LoadScript("big_aux.lua")
Duel.LoadScript("c420.lua")

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
local ARCHETYPE=0x15a

--All "Jutte" and "Goyo" monsters or Samusata Gardna in your possession are also treated as "S-Force" monsters.
function s.archetypefilter(c)
  return c:IsGoyo() or c:IsJutte() or c:IsCode(511001748)
end

function s.smallsforcefiltertuna(_,c)
	return (c:IsSetCard(0x15a) and c:IsLevelBelow(3)) or c:IsCode(511001748)
end


function s.supertypefilter(c)
	return c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ) or c:IsType(TYPE_LINK)
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

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATIONS,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(ARCHETYPE)
        Duel.RegisterEffect(e5,tp)

		local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_TYPE)
        e6:SetTargetRange(LOCATION_MZONE,0)
        e6:SetTarget(s.smallsforcefiltertuna)
        e6:SetValue(TYPE_TUNER)
        Duel.RegisterEffect(e6,tp)


		local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_ATTRIBUTE)
        e7:SetTargetRange(LOCATION_MZONE,0)
        e7:SetTarget(function(_,c)  return c:IsSetCard(0x15a) end)
        e7:SetValue(ATTRIBUTE_EARTH)
        Duel.RegisterEffect(e7,tp)

		local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_ATTRIBUTE)
        e8:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e8:SetValue(ATTRIBUTE_EARTH)
        Duel.RegisterEffect(e8,tp)

		local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_TYPE)
        e9:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e9:SetValue(TYPE_SYNCHRO)
        Duel.RegisterEffect(e9,tp)

		local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_ADD_RACE)
        e10:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
        e10:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e10:SetValue(RACE_WARRIOR)
        Duel.RegisterEffect(e10,tp)

		local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_ADD_SETCODE)
        e11:SetTargetRange(LOCATION_HAND,0)
        e11:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e11:SetValue(0x52d)
        Duel.RegisterEffect(e11,tp)

	end
	e:SetLabel(1)
end


function s.markedfilter(c,e)
    return #c:IsHasEffect(e)>0
end


function s.archetypefilter2(c)
	return c:IsSetCard(0x15a) and c:IsLevelBelow(4)
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

	g=Duel.GetMatchingGroup(s.supertypefilter, tp, LOCATION_ALL, LOCATION_ALL, nil)

	
    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+1)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

	g=Duel.GetMatchingGroup(s.archetypefilter2, tp, LOCATION_ALL, LOCATION_ALL, nil)

	
    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+2)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

