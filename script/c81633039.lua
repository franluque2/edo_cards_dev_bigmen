--Conscription of Thunder Spark
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
local LOCATIONS=LOCATION_ONFIELD-LOCATION_OVERLAY

--add archetype setcode here
local ARCHETYPE=0x565

--add the conditions for the archetype swap here
function s.archetypefilter(c)
  return c:IsRace(RACE_THUNDER)
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
        e5:SetTarget(function(_,c)  return s.archetypefilter(c) end)
        e5:SetValue(ARCHETYPE)
        Duel.RegisterEffect(e5,tp)
    
        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_ADJUST)
		e9:SetCondition(s.removeloccon)
		e9:SetOperation(s.removelocop)
        Duel.RegisterEffect(e9,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
		e10:SetType(EFFECT_TYPE_FIELD)
		e10:SetCode(EFFECT_XYZ_LEVEL)
		e10:SetTargetRange(LOCATION_MZONE, 0)
		e10:SetTarget(function (_,c) return c:IsCode(511008506, 511008507) end)
		e10:SetValue(s.xyzlv)
        Duel.RegisterEffect(e10,tp)

	end
	e:SetLabel(1)
end


function s.markedfilter(c,e)
    return #c:IsHasEffect(e)>0
end

function s.SparkDragonfilter(c)
    return c:IsType(TYPE_XYZ) and c:IsCode(84417082)
end

function s.xyzlv(e,c,rc)
	return 0x40000+rc:GetLevel()
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

    local g=Duel.GetMatchingGroup(s.SparkDragonfilter,tp,LOCATION_EXTRA,0,nil)
    local tc=g:GetFirst()
    while tc do
        Xyz.AddProcedure(tc,nil,4,4,nil,nil,99)
        tc=g:GetNext()
    end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.removeloccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON)
end
function s.removelocop(e,tp,eg,ep,ev,re,r,rp)
	while Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON) and Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON):GetHandler():IsCode(48049769) do
        local ef=Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON)
        if ef:GetHandler():IsCode(48049769) then
            ef:Reset()
        end
	end
end
