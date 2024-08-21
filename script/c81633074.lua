--Conscription of the Shining Pegasus
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
function s.archetypefilter(c)
  return c:IsType(TYPE_CONTINUOUS) and c:IsSpellTrap()
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
        e5:SetTarget(function(_,c)  return c:IsMonster() end)
        e5:SetValue(0x8e)
        Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_ATTRIBUTE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(function(_,c)  return c:IsMonster() end)
        e6:SetValue(ATTRIBUTE_DARK)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_RACE)
        e7:SetTargetRange(LOCATIONS,0)
        e7:SetTarget(function(_,c)  return c:IsMonster() end)
        e7:SetValue(RACE_ZOMBIE)
        Duel.RegisterEffect(e7,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_SETCODE)
        e8:SetTargetRange(LOCATIONS,0)
        e8:SetTarget(function(_,c)  return c:IsMonster() end)
        e8:SetValue(0x142)
        Duel.RegisterEffect(e8,tp)

        local e18=Effect.CreateEffect(e:GetHandler())
        e18:SetType(EFFECT_TYPE_FIELD)
        e18:SetCode(EFFECT_ADD_SETCODE)
        e18:SetTargetRange(LOCATIONS,0)
        e18:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e18:SetValue(0x144)
        Duel.RegisterEffect(e18,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_CANNOT_DISEFFECT)
        e9:SetValue(s.effectfilter)
        Duel.RegisterEffect(e9,tp)

        local e19=Effect.CreateEffect(e:GetHandler())
        e19:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
        e19:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e19:SetCode(EVENT_SPSUMMON_SUCCESS)
        e19:SetOperation(s.mreborncheck)
        Duel.RegisterEffect(e19,tp)
    

	end
	e:SetLabel(1)
end

function s.mreborncheck(e,tp,eg,ev,ep,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	if (rc:IsCode(24062258)) then
		local ec=eg:GetFirst()
		while ec do
			ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
			ec=eg:GetNext()
		end
	end
end


function s.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	local tc=te:GetHandler()
	return p==tp and (loc&LOCATION_ONFIELD)~=0 and tc~=e:GetHandler() and tc:GetFlagEffect(id)>0
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

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

