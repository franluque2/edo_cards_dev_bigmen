--Conscription of Red Nova's Servant
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
  return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DINOSAUR)
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
    


        --the self floodgate stuff starts here

        -- boat hopt
    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetOperation(s.aclimit1)
    Duel.RegisterEffect(e2, tp)

    local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.econ1)
	e4:SetValue(s.elimit)
    Duel.RegisterEffect(e4, tp)

    --yomi guardian banish

    local e9=Effect.CreateEffect(e:GetHandler())
    e9:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e9:SetCode(EVENT_SPSUMMON_SUCCESS)
    e9:SetOperation(s.mreborncheck)
    Duel.RegisterEffect(e9,tp)


    local e10=Effect.CreateEffect(e:GetHandler())
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e10:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e10:SetTarget(s.rmtarget)
	e10:SetTargetRange(LOCATION_MZONE,0)
	e10:SetValue(LOCATION_REMOVED)
    Duel.RegisterEffect(e10,tp)

	--immunity
	local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(s.indestg)
	e6:SetValue(s.indval)
	Duel.RegisterEffect(e6,tp)

	end
	e:SetLabel(1)
end

function s.indval(e,re,rp)
	return re:GetOwner():IsCode(511001689)
end

function s.indestg(e,c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)
end





function s.mreborncheck(e,tp,eg,ev,ep,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	if (rc:IsCode(513000112) and eg:GetFirst():IsCode(511001688)) then
		local ec=eg:GetFirst()
		while ec do
			ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
			ec=eg:GetNext()
		end
	end
end

function s.rmtarget(e,c)
	if not c:IsLocation(0x80) and c:IsReason(REASON_DESTROY) and (c:GetFlagEffect(id)>0) and Duel.IsBattlePhase() then
		return true
	else
		return false
	end
end

function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-tp or not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_GRAVE) and re:GetHandler():IsCode(513000112)) then return end
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,0)
end
function s.econ1(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+1)>=1
end
function s.elimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_GRAVE) and re:GetHandler():IsCode(513000112)
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


