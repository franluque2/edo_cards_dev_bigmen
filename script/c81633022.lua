--Ancient Fairy Conscription
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


--add the conditions for the archetype swap here
function s.archetypefilter(c)
  return c:IsCode(25862681, 02403771, 25165047)
end



function s.isfairybeastplant(c)
    return c:IsRace(RACE_PLANT) or c:IsRace(RACE_BEAST) or c:IsRace(RACE_FAIRY)
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
        e5:SetCode(EFFECT_ADD_CODE)
        e5:SetTargetRange(LOCATIONS,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(CARD_VISAS_STARFROST)
        Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e6:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e6:SetTarget(function(_,c)  return s.isfairybeastplant(c) end)
        e6:SetValue(ATTRIBUTE_LIGHT)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetTargetRange(LOCATION_MZONE,0)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)



        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_ADD_SETCODE)
        e3:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e3:SetTarget(function(_,c)  return s.isfairybeastplant(c) end)
        e3:SetValue(SET_MANNADIUM)
        Duel.RegisterEffect(e3,tp)

        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_ADD_SETCODE)
        e4:SetTargetRange(LOCATION_DECK,0)
        e4:SetTarget(function(_,c)  return s.isfairybeastplant(c) and c:IsLevelBelow(3) end)
        e4:SetValue(0x51d)
        Duel.RegisterEffect(e4,tp)
    

	end
	e:SetLabel(1)
end



function s.efilter(e,te)
	return te:GetHandler():IsCode(87624166)
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

    local kuribons=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, LOCATION_ALL, nil,47432275)

    if #kuribons>0 then
		local tc=kuribons:GetFirst()
		while tc do
			
            local e8=Effect.CreateEffect(e:GetHandler())
            e8:SetType(EFFECT_TYPE_SINGLE)
            e8:SetRange(LOCATION_MZONE)
            e8:SetCode(30765615)
            tc:RegisterEffect(e8)
        

            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SYNCHRO_LEVEL)
            e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e1:SetRange(LOCATION_ONFIELD)
            e1:SetValue(function(e) return 3*65536+e:GetHandler():GetLevel() end)
            tc:RegisterEffect(e1)

			tc=kuribons:GetNext()
		end
	end
    

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
