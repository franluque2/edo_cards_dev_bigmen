--Conscription of the Kung Fu Champion
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
function s.Warriors(c)
  return c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(4)
end

function s.WarriorsNyan(c)
  return (c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(4)) or c:IsCode(70797118)
end

function s.Dragons(c)
  return c:IsOriginalRace(RACE_DRAGON) and c:IsLevelBelow(5)
end

function s.Kiryu(c)
  return c:IsCode(84814897)
end

function s.BigCards(c)
	return c:IsCode(86805855, 810000093)
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

        --The name of all Level 4 or lower Warrior monsters in your Hand, Deck and GY are also treated as "Dark Blade".
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_CODE)
        e5:SetTargetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(11321183)
        Duel.RegisterEffect(e5,tp)

        --The name of all Level 5 or lower monsters in your Hand, Deck and GY whose original Type is Dragon are also treated as "Pitch-Dark Dragon".
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_CODE)
        e6:SetTargetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e6:SetValue(47415292)
        Duel.RegisterEffect(e6,tp)

        --All monsters you control become LIGHT.
        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e7:SetTargetRange(LOCATION_MZONE,0)
        e7:SetValue(ATTRIBUTE_LIGHT)
        Duel.RegisterEffect(e7,tp)

        --All monsters In your Deck become Dragons.
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_RACE)
        e8:SetTargetRange(LOCATION_DECK,0)
        e8:SetValue(RACE_DRAGON)
        Duel.RegisterEffect(e8,tp)

		--All "Kiryu" in deck become level 4
        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_CHANGE_LEVEL)
        e9:SetTargetRange(LOCATION_DECK,0)
		e9:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e9:SetValue(4)
        Duel.RegisterEffect(e9,tp)

		--The name of all Level 4 or lower Warrior monsters and all "Thunder Nyan Nyan" you control are also treated as "Kung Fu Nyan Nyan".
        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_ADD_CODE)
        e10:SetTargetRange(LOCATION_MZONE,0)
        e10:SetTarget(function(_,c)  return c:IsHasEffect(id+3) end)
        e10:SetValue(810000091)
        Duel.RegisterEffect(e10,tp)

		--The name of all Level 5 or lower Dragon monsters you control are also treated as "Master Kyonshee".
        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_ADD_CODE)
        e11:SetTargetRange(LOCATION_MZONE,0)
        e11:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e11:SetValue(24530661)
        Duel.RegisterEffect(e11,tp)

		--The name of all "Dark Blade the Dragon Knight" and "Dragon Lady" you control are also treated as "Dark Blade".
        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_ADD_CODE)
        e12:SetTargetRange(LOCATION_MZONE,0)
        e12:SetTarget(function(_,c)  return c:IsHasEffect(id+4) end)
        e12:SetValue(11321183)
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

    local g=Duel.GetMatchingGroup(s.Warriors, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.Dragons, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.Kiryu, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

	g=Duel.GetMatchingGroup(s.WarriorsNyan, tp, LOCATION_ALL, LOCATION_ALL, nil)

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
	
	g=Duel.GetMatchingGroup(s.BigCards, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

