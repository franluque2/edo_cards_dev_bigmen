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
local ARCHETYPE=0x516

--add the conditions for the archetype swap here
function s.archetypefilter(c)
  return c:IsCode(79182538, 511002432, 11987744, 86652646, 26302107, 32349062, 65479980, 23297235, 39246582, 47929865, 96930127, 100000540, 72714226, 01003028, 94667532, 511013008, 70271583, 15475415, 57346400, 12076263, 58616392, 60643553, 25273572, 11548522, 71583486, 86889202)
end

function s.archetypefilterbutnotDogWood(c)
    return c:IsCode(79182538, 511002432, 11987744, 86652646, 26302107, 32349062, 65479980, 23297235, 39246582, 47929865, 96930127, 100000540, 72714226, 01003028, 94667532, 511013008, 70271583, 15475415, 57346400, 12076263, 58616392, 25273572, 11548522, 71583486, 86889202)
end

function s.Tribulldog(c)
    return c:IsCode(100000540)
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
        e6:SetCode(EFFECT_CHANGE_RACE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e6:SetValue(RACE_BEAST)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_CODE)
        e7:SetTargetRange(LOCATION_DECK,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e7:SetValue(11548522)
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

    g=Duel.GetMatchingGroup(s.archetypefilterbutnotDogWood, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.Tribulldog, tp, LOCATION_ALL, LOCATION_ALL, nil)

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
