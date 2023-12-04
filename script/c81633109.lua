--Righteous Conscription of the Law
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
local ARCHETYPE=0x1186

--add the conditions for the archetype swap here
function s.JutteMons(c)
  return c:IsOriginalSetCard(0x52d) or c:IsCode(60410769)
end

function s.VigilMons(c)
  return c:IsOriginalSetCard(0x55c)
end

function s.EtcMons(c)
  return c:IsCode(72714226, 97904474, 27870033, 14344682, 80885324, 08102334, 511000016, 13521194, 50732780)
end

function s.Stygians(c)
  return c:IsCode(13521194, 50732780)
end

function s.HandTargets(c)
  return c:IsType(TYPE_MONSTER)
end

function s.Torapart(c)
  return c:IsCode(83370323)
end

function s.Sergeants(c)
  return c:IsCode(86137485)
end

function s.Prisoners(c)
  return c:GetControler()~=c:GetOwner()
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
        e5:SetTargetRange(LOCATION_HAND,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(0x55c)
        Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_SETCODE)
        e6:SetTargetRange(LOCATION_HAND,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e6:SetValue(0x52d)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_SETCODE)
        e7:SetTargetRange(LOCATION_HAND,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e7:SetValue(0x52d)
        Duel.RegisterEffect(e7,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_SETCODE)
        e8:SetTargetRange(LOCATION_HAND,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e8:SetValue(0x55c)
        Duel.RegisterEffect(e8,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_RACE)
        e9:SetTargetRange(LOCATION_HAND,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id+4) end)
        e9:SetValue(RACE_FIEND)
        Duel.RegisterEffect(e9,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_ADD_ATTRIBUTE)
        e10:SetTargetRange(LOCATIONS,0)
        e10:SetTarget(function(_,c)  return c:IsHasEffect(id+5) end)
        e10:SetValue(ATTRIBUTE_EARTH)
        Duel.RegisterEffect(e10,tp)

		local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_ADD_ATTRIBUTE)
        e11:SetTargetRange(LOCATION_MZONE,0)
        e11:SetTarget(aux.TargetBoolFunction(s.Prisoners))
        e11:SetValue(ATTRIBUTE_EARTH)
        Duel.RegisterEffect(e11,tp)

		local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_ADD_RACE)
        e12:SetTargetRange(LOCATION_MZONE,0)
        e12:SetTarget(aux.TargetBoolFunction(s.Prisoners))
        e12:SetValue(RACE_WARRIOR)
        Duel.RegisterEffect(e12,tp)
    
		local e13=Effect.CreateEffect(e:GetHandler())
        e13:SetType(EFFECT_TYPE_FIELD)
        e13:SetCode(EFFECT_ADD_TYPE)
        e13:SetTargetRange(LOCATION_MZONE,0)
        e13:SetTarget(aux.TargetBoolFunction(s.Prisoners))
        e13:SetValue(TYPE_SYNCHRO)
        Duel.RegisterEffect(e13,tp) 

		local e14=Effect.CreateEffect(e:GetHandler())
		e14:SetType(EFFECT_TYPE_FIELD)
        e14:SetTargetRange(LOCATION_MZONE,0)
		e14:SetCode(EFFECT_CANNOT_RELEASE)
		e14:SetTarget(aux.TargetBoolFunction(s.Prisoners))
		e14:SetValue(1)
        Duel.RegisterEffect(e14,tp)
    

	end
	e:SetLabel(1)
end

function s.synval(e,mc,sc) --this effect, this card and the monster to be summoned
	return sc:IsRace(RACE_WARRIOR) and sc:IsAttribute(ATTRIBUTE_EARTH)
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

    local g=Duel.GetMatchingGroup(s.JutteMons, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.VigilMons, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.EtcMons, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.Stygians, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+3)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    g=Duel.GetMatchingGroup(s.HandTargets, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+4)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    g=Duel.GetMatchingGroup(s.Torapart, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+5)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    local EndDragons=Duel.GetMatchingGroup(s.Sergeants, tp, LOCATION_EXTRA, 0, nil)
	if #EndDragons>0 then
	  local tc=EndDragons:GetFirst()
		while tc do
	  
		--synchro summon
		Synchro.AddProcedure(tc,nil,1,1,Synchro.NonTuner(nil),1,99)
		  tc=EndDragons:GetNext()
		end
	end

	g=Duel.GetMatchingGroup(s.Stygians, tp, LOCATION_ALL, 0, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_SYNCHRO_MAT_FROM_HAND)
			e1:SetRange(LOCATION_HAND)
			e1:SetCountLimit(1,id)
			e1:SetValue(s.synval)
			tc:RegisterEffect(e1)


			tc=g:GetNext()
		end
	end

	

	

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

