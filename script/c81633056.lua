--Conscription for Dogs
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
function s.GOODBOYS(c)
  return c:IsCode(100000498, 79182538, 11987744, 86652646, 23297235, 65479980, 39246582, 96930127, 72714226, 01003028, 94667532, 70271583, 15475415, 57346400, 12076263, 25273572, 11548522, 71583486, 86889202)
end

function s.Backrow(c)
    return c:IsCode(100000541, 511000038, 511001676, 511002944)
end

function s.Dog(c)
    return c:IsDog()
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

        --Dogs correctly being Dogs
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATIONS,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(0x516)
        Duel.RegisterEffect(e5,tp)

        --All "Dog" Monsters in your possession are treated as EARTH Beast Cyberse "S-Force", "Alien", "Karakuri", "Fluffal" monsters. 
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_SETCODE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e6:SetValue(0x15a)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_SETCODE)
        e7:SetTargetRange(LOCATIONS,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e7:SetValue(0xa9)
        Duel.RegisterEffect(e7,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_SETCODE)
        e8:SetTargetRange(LOCATIONS,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e8:SetValue(0xc)
        Duel.RegisterEffect(e8,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_SETCODE)
        e9:SetTargetRange(LOCATIONS,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e9:SetValue(0x11)
        Duel.RegisterEffect(e9,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_ADD_RACE)
        e10:SetTargetRange(LOCATIONS,0)
        e10:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e10:SetValue(RACE_BEAST)
        Duel.RegisterEffect(e10,tp)

        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_ADD_RACE)
        e11:SetTargetRange(LOCATIONS,0)
        e11:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e11:SetValue(RACE_CYBERSE)
        Duel.RegisterEffect(e11,tp)

        local e13=Effect.CreateEffect(e:GetHandler())
        e13:SetType(EFFECT_TYPE_FIELD)
        e13:SetCode(EFFECT_ADD_RACE)
        e13:SetTargetRange(LOCATIONS,0)
        e13:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e13:SetValue(ATTRIBUTE_EARTH)
        Duel.RegisterEffect(e13,tp)

        --All monsters in Deck treated as FIRE
        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_ADD_ATTRIBUTE)
        e12:SetTargetRange(LOCATION_DECK,0)
        e12:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e12:SetValue(ATTRIBUTE_FIRE)
        Duel.RegisterEffect(e12,tp)

        --All "Dogking", "Doubulldog", "Pooch Party", "Raise the Woof" and "Superior Howl" in your possession are treated as "G Golem" cards.
        local e14=Effect.CreateEffect(e:GetHandler())
        e14:SetType(EFFECT_TYPE_FIELD)
        e14:SetCode(EFFECT_ADD_SETCODE)
        e14:SetTargetRange(LOCATIONS,0)
        e14:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e14:SetValue(0x187)
        Duel.RegisterEffect(e14,tp)

        --Xyz
        local e15=Effect.CreateEffect(e:GetHandler())
        e15:SetType(EFFECT_TYPE_FIELD)
        e15:SetCode(EFFECT_XYZ_LEVEL)
        e15:SetTargetRange(LOCATION_MZONE, 0)
        e15:SetTarget(function(_,c)  return c:IsMonster() and c:HasLevel() end)
        e15:SetValue(s.xyzlv)
        Duel.RegisterEffect(e15,tp)

        --Monsters become "Tribulldog"
        local e16=Effect.CreateEffect(e:GetHandler())
        e16:SetType(EFFECT_TYPE_FIELD)
        e16:SetCode(EFFECT_ADD_CODE)
        e16:SetTargetRange(LOCATIONS, 0)
        e16:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e16:SetValue(100000540)
        Duel.RegisterEffect(e16,tp)
    
    

	end
	e:SetLabel(1)
end

function s.xyzlv(e,c,rc)
    if rc:IsCode(100000498) then
        return 4, c:GetLevel()
    else return c:GetLevel()
    end
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

    local g=Duel.GetMatchingGroup(s.GOODBOYS, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.Backrow, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.Dog, tp, LOCATION_ALL, LOCATION_ALL, nil)

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


