--Conscription of the Cybernetic Turtle
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

--add the conditions for the archetype swap here
function s.TOITLES(c)
  return c:IsCode(9973359, 12275533, 53724621, 72929454, 96981563, 11714098, 04042268, 37313348, 15820147, 17441953, 55063751, 95727991, 05818294, 60806437, 42868711, 77044671, 07913375, 96287685, 65195959, 64734090, 34710660, 03493978, 89113320, 80233946, 76902476, 54747648, 91782219, 09540040, 10132124, 82176812, 46358784, 68215963)
end

function s.BIGBOI(c)
    return c:IsCode(55063751, 39439590, 99733359, 12275533)
end

function s.NotJapan(c)
    return c:IsCode(56111151)
end

function s.StillNotJapan(c)
    return (c:IsSetCard(0xd3) and c:IsSpellTrap()) or c:IsCode(76806714) or c:IsCode(24094653)
end

function s.JustDinoMoment(c)
    return c:IsCode(39439590)
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

        --Extra Normal Summon
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e2:SetCode(EFFECT_EXTRA_SET_COUNT)
        e2:SetDescription(aux.Stringid(id,0))
        Duel.RegisterEffect(e2,tp)
        local e15=e2:Clone()
        e15:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        Duel.RegisterEffect(e15, tp)


        --Flip on summon turn
        local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_MSET)
		e3:SetOperation(s.setstatuschange)
		Duel.RegisterEffect(e3,tp)

        --Turtles also treated as FIRE in Deck
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_ATTRIBUTE)
        e5:SetTargetRange(LOCATION_DECK,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(ATTRIBUTE_FIRE)
        Duel.RegisterEffect(e5,tp)

        --Turtles also treated as Zombies in Deck
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_RACE)
        e6:SetTargetRange(LOCATION_DECK,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e6:SetValue(RACE_ZOMBIE)
        Duel.RegisterEffect(e6,tp)

        --Turtles also treated as Kaijus in Deck
        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_SETCODE)
        e7:SetTargetRange(LOCATION_DECK,LOCATION_MZONE)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e7:SetValue(0xd3)
        Duel.RegisterEffect(e7,tp)

        --Turtles also treated as GemFusion in Deck
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_CODE)
        e8:SetTargetRange(LOCATION_DECK,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e8:SetValue(1264319)
        Duel.RegisterEffect(e8,tp)

        --CyberDino&Gameciel become Gaia
        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_SETCODE)
        e9:SetTargetRange(LOCATION_DECK+LOCATION_HAND,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e9:SetValue(0xbd)
        Duel.RegisterEffect(e9,tp)
    
        --Monsters in hand become WATER
        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_ADD_ATTRIBUTE)
        e10:SetTargetRange(LOCATION_HAND,0)
        e10:SetValue(ATTRIBUTE_WATER)
        Duel.RegisterEffect(e10,tp)

        --Monsters in hand become Don Turtle
        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_ADD_CODE)
        e11:SetTargetRange(LOCATION_HAND,0)
        e11:SetValue(03493978)
        Duel.RegisterEffect(e11,tp)

        --Monsters in PLACES become WATER
        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_ADD_ATTRIBUTE)
        e12:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0)
        e12:SetValue(ATTRIBUTE_WATER)
        Duel.RegisterEffect(e12,tp)

        --Monsters in PLACES become Aqua
        local e13=Effect.CreateEffect(e:GetHandler())
        e13:SetType(EFFECT_TYPE_FIELD)
        e13:SetCode(EFFECT_ADD_RACE)
        e13:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0)
        e13:SetValue(RACE_AQUA)
        Duel.RegisterEffect(e13,tp)

        --Monsters you control become Bujins
        local e14=Effect.CreateEffect(e:GetHandler())
        e14:SetType(EFFECT_TYPE_FIELD)
        e14:SetCode(EFFECT_ADD_SETCODE)
        e14:SetTargetRange(LOCATION_MZONE,0)
        e14:SetValue(0x88)
        Duel.RegisterEffect(e14,tp)

        --Waterfront is too many cards
        local e15=Effect.CreateEffect(e:GetHandler())
        e15:SetType(EFFECT_TYPE_FIELD)
        e15:SetCode(EFFECT_CHANGE_CODE)
        e15:SetTargetRange(LOCATION_FZONE,0)
        e15:SetTarget(function(_,c) return c:IsHasEffect(id+2) end)
        e15:SetValue(12644061)
        Duel.RegisterEffect(e15,tp)

        local e16=Effect.CreateEffect(e:GetHandler())
        e16:SetType(EFFECT_TYPE_FIELD)
        e16:SetCode(EFFECT_ADD_CODE)
        e16:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY-LOCATION_ONFIELD,0)
        e16:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e16:SetValue(1264319)
        Duel.RegisterEffect(e16,tp)


        --Kaiju Cards
        local e18=Effect.CreateEffect(e:GetHandler())
        e18:SetType(EFFECT_TYPE_FIELD)
        e18:SetCode(EFFECT_CHANGE_CODE)
        e18:SetTargetRange(LOCATION_DECK,0)
        e18:SetTarget(function(_,c)  return c:IsHasEffect(id+3) end)
        e18:SetValue(1264319)
        Duel.RegisterEffect(e18,tp)

        --Gora
        local e20=Effect.CreateEffect(e:GetHandler())
        e20:SetType(EFFECT_TYPE_FIELD)
        e20:SetCode(EFFECT_IMMUNE_EFFECT)
        e20:SetTargetRange(LOCATION_MZONE,0)
        e20:SetValue(s.efilter)
        Duel.RegisterEffect(e20, tp)

        --Monsters in PLACES become Dinosaurs
        local e21=Effect.CreateEffect(e:GetHandler())
        e21:SetType(EFFECT_TYPE_FIELD)
        e21:SetCode(EFFECT_ADD_RACE)
        e21:SetTargetRange(LOCATION_MZONE+LOCATION_HAND,0)
        e21:SetValue(RACE_DINOSAUR)
        Duel.RegisterEffect(e21,tp)

        --CyberDino becomes Stegocyber
        local e22=Effect.CreateEffect(e:GetHandler())
        e22:SetType(EFFECT_TYPE_FIELD)
        e22:SetCode(EFFECT_ADD_CODE)
        e22:SetTargetRange(LOCATIONS,0)
        e22:SetTarget(function(_,c)  return c:IsHasEffect(id+4) end)
        e22:SetValue(99733359)
        Duel.RegisterEffect(e22,tp)

	end
	e:SetLabel(1)
end


function s.markedfilter(c,e)
    return #c:IsHasEffect(e)>0
end

function s.setstatuschange(e,tp,eg,ev,ep,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.GetTurnPlayer()==tp then
		tc:SetStatus(STATUS_SUMMON_TURN, false)
	end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(s.TOITLES, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.BIGBOI, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.NotJapan, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.StillNotJapan, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.JustDinoMoment, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.efilter(e,te)
	return te:GetHandler():IsCode(80233946)
end