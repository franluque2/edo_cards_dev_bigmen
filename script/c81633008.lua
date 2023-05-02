--Conscription of Light & Darkness' End
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

--Dragonic Warrior
function s.archetypefilter(c)
  return c:IsCode(511002255)
end

--Dragons
function s.archetypefilter2(c)
    return c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON)
end

--Light End Dark End
function s.LightDarkEnd(c)
	return c:IsCode(25132288, 88643579)
end

--Burning Dragon
function s.archetypefilter3(c)
	return c:IsCode(08085950)
end

--Dragonic Knight
function s.archetypefilter4(c)
	return c:IsCode(38109772)
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
        e5:SetCode(EFFECT_ADD_RACE)
        e5:SetTargetRange(LOCATIONS,0)
        e5:SetTarget(aux.TargetBoolFunction(s.archetypefilter))
        e5:SetValue(RACE_DRAGON)
        Duel.RegisterEffect(e5,tp)
    
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_ATTRIBUTE)
        e6:SetTargetRange(LOCATION_DECK,0)
        e6:SetTarget(aux.TargetBoolFunction(s.archetypefilter2))
        e6:SetValue(ATTRIBUTE_WIND)
        Duel.RegisterEffect(e6,tp)

		local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_ATTRIBUTE)
        e7:SetTargetRange(LOCATION_ONFIELD,0)
        e7:SetTarget(aux.TargetBoolFunction(s.archetypefilter3))
        e7:SetValue(ATTRIBUTE_DARK)
        Duel.RegisterEffect(e7,tp)

		local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_ATTRIBUTE)
        e8:SetTargetRange(LOCATION_ONFIELD,0)
        e8:SetTarget(aux.TargetBoolFunction(s.archetypefilter3))
        e8:SetValue(ATTRIBUTE_LIGHT)
        Duel.RegisterEffect(e8,tp)

		local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_CODE)
        e9:SetTargetRange(LOCATION_ONFIELD,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e9:SetValue(511002255)
        Duel.RegisterEffect(e9,tp)

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

    local g=Duel.GetMatchingGroup(s.archetypefilter4, tp, LOCATION_ALL, LOCATION_ALL, nil)

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
	local EndDragons=Duel.GetMatchingGroup(s.LightDarkEnd, tp, LOCATION_EXTRA, 0, nil)
	if #EndDragons>0 then
	  local tc=EndDragons:GetFirst()
		while tc do
	  
		--synchro summon
		Synchro.AddProcedure(tc,nil,1,1,Synchro.NonTuner(nil),1,99)
		  tc=EndDragons:GetNext()
		end
	end
  
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

