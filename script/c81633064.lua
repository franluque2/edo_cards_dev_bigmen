--Parasite Conscription
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
local ARCHETYPE=0x182

--add the conditions for the archetype swap here
function s.ParaQueen(c)
  return c:IsCode(06205579, 511009344)
end

function s.Backrow(c)
  return c:IsCode(511009326, 511009345, 511009341, 511009324, 511009339, 511009347)
end

function s.Tear(c)
  return c:IsOriginalSetCard(0x182)
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
        e6:SetCode(EFFECT_ADD_SETCODE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e6:SetValue(ARCHETYPE)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_SETCODE)
        e7:SetTargetRange(LOCATIONS,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e7:SetValue(0x9b)
        Duel.RegisterEffect(e7,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_SETCODE)
        e8:SetTargetRange(LOCATIONS,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e8:SetValue(0xdf)
        Duel.RegisterEffect(e8,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_SETCODE)
        e9:SetTargetRange(LOCATIONS,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e9:SetValue(0xf7)
        Duel.RegisterEffect(e9,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_ADD_SETCODE)
        e10:SetTargetRange(LOCATIONS,0)
        e10:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e10:SetValue(0xf0)
        Duel.RegisterEffect(e10,tp)

        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_CANNOT_TRIGGER)
        e11:SetTargetRange(LOCATION_FZONE,0)
        e11:SetCondition(s.discon)
        e11:SetTarget(s.actfilter)
        Duel.RegisterEffect(e11, tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetTargetRange(LOCATION_GRAVE,0)
        e2:SetTarget(s.immtar)
        e2:SetValue(s.value)
        Duel.RegisterEffect(e2,tp)
	end
	e:SetLabel(1)
end

function s.value(e,re,rp)
	local trig_cod,eff=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_EFFECT)
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
		and (re:GetHandler():IsCode(25793414) or (eff==re and trig_cod==25793414))
end

function s.immtar(e,c)
	return c:IsCode(76815942)
end


function s.discon(e)
	return Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()
end

function s.actfilter(e,c)
	return c:IsCode(77103950)
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

    local g=Duel.GetMatchingGroup(s.ParaQueen, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    g=Duel.GetMatchingGroup(s.Tear, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    local BloomPrima=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 24672164)
    if #BloomPrima>0 then
	local tc=BloomPrima:GetFirst()
		while tc do
	
            Fusion.AddProcMix(tc,true,true,06205579,aux.FilterBoolFunctionEx(Card.IsSetCard,0x9b))


			tc=BloomPrima:GetNext()
		end
    end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

