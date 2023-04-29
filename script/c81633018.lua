--Jurassic Conscription
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


--Tyrant Dragon
function s.archetypefilter(c)
    return c:IsCode(94568601)
  end

--Jurassic Cards
function s.archetypefilter2(c)
    return c:IsCode(23969415, 99531088, 76076738, 511000895)
  end

--All Dinosaur Monsters become DARK.
function s.archetypefilter3(c)
    return c:IsRace(RACE_DINOSAUR)
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

        --Tyrant Dragon in possession becomes a Dinosaur.
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_ADD_RACE)
        e3:SetTargetRange(LOCATIONS,0)
        e3:SetTarget(aux.TargetBoolFunction(s.archetypefilter))
        e3:SetValue(RACE_DINOSAUR)
        Duel.RegisterEffect(e3,tp)

        --Monsters in possession also become DARK.
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_ADD_ATTRIBUTE)
        e4:SetTargetRange(LOCATIONS,0)
        e4:SetTarget(aux.TargetBoolFunction(s.archetypefilter3))
        e4:SetValue(ATTRIBUTE_DARK)
        Duel.RegisterEffect(e4,tp)
    
        --Jurassic Cards in Deck/GY also become Polymerization
        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_CODE)
        e7:SetTargetRange(LOCATION_DECK+LOCATION_GRAVE,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e7:SetValue(24094653)
        Duel.RegisterEffect(e7,tp)
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

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
