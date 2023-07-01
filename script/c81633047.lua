--Conscription of the Determined Truesdale
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
function s.Roids(c)
  return c:IsSetCard(0x16)
end

function s.RoidOriginal(c)
  return c:IsOriginalSetCard(0x16)
end

function s.CyberConnection(c)
  return c:IsSetCard(0x93)
end

function s.RoidConnection(c)
  return c:IsSetCard(0x16) or c:IsCode(23299957)
end

function s.Steamroid(c)
  return c:IsOriginalCode(44729197)
end

function s.Drillroid(c)
  return c:IsOriginalCode(71218746)
end

function s.Submarineroid(c)
  return c:IsOriginalCode(99861526)
end

function s.Horn(c)
  return c:IsOriginalCode(41230939)
end

function s.Edge(c)
  return c:IsOriginalCode(77625948)
end

function s.Keel(c)
  return c:IsOriginalCode(03019642)
end

function s.vczop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,LOCATION_ALL,nil,23299957)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id,0,0,0)
        local eff=tc:GetActivateEffect()
        eff:Reset()
        tc:RegisterEffect(Fusion.CreateSummonEff(tc,aux.FilterBoolFunction(Card.IsSetCard,0x16),nil,nil,nil,nil,s.stage2))
    end
end

function s.stage2(e,tc,tp,sg,chk)
    if chk==1 then
        local c=e:GetHandler()
        --Cannot be destroyed by card effects
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(3001)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1,true)
        --Cannot be negated
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(3308)
        e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_DISABLE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2,true)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_CANNOT_DISEFFECT)
        e3:SetRange(LOCATION_MZONE)
        e3:SetValue(s.efilter)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3,true)
    end
end

function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
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

        --All Roid monsters are also treated as Cyberdarks
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATIONS,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(0x4093)
        Duel.RegisterEffect(e5,tp)

        --All "Cyber" Spell/Trap Cards in your possession are also treated as "Roid" cards.
        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_SETCODE)
        e7:SetTargetRange(LOCATIONS,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e7:SetValue(0x16)
        Duel.RegisterEffect(e7,tp)

        --All "Vehicroid Connection Zone" and all "Roid" Spell/Trap Cards in your possession are also treated as "Cyberdark" cards.
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_SETCODE)
        e8:SetTargetRange(LOCATIONS,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e8:SetValue(0x4093)
        Duel.RegisterEffect(e8,tp)

        --Name Swaps
        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_CODE)
        e9:SetTargetRange(LOCATIONS,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id+3) end)
        e9:SetValue(41230939)
        Duel.RegisterEffect(e9,tp)
    

        local e10=e9:Clone()
        e10:SetTarget(function(_,c)  return c:IsHasEffect(id+4) end)
        e10:SetValue(77625948)
        Duel.RegisterEffect(e10,tp)

        local e11=e9:Clone()
        e11:SetTarget(function(_,c)  return c:IsHasEffect(id+5) end)
        e11:SetValue(03019642) 
        Duel.RegisterEffect(e11,tp)

        local e12=e9:Clone()
        e12:SetTarget(function(_,c)  return c:IsHasEffect(id+6) end)
        e12:SetValue(44729197)
        Duel.RegisterEffect(e12,tp)

        local e13=e9:Clone()
        e13:SetTarget(function(_,c)  return c:IsHasEffect(id+7) end)
        e13:SetValue(71218746)
        Duel.RegisterEffect(e13,tp)

        local e14=e9:Clone()
        e14:SetTarget(function(_,c)  return c:IsHasEffect(id+8) end)
        e14:SetValue(99861526)
        Duel.RegisterEffect(e14,tp)

        local e0=Effect.CreateEffect(e:GetHandler())
        e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e0:SetCode(EVENT_ADJUST)
        e0:SetOperation(s.vczop)
        Duel.RegisterEffect(e0,tp)

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

    local g=Duel.GetMatchingGroup(s.Roids, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    local g=Duel.GetMatchingGroup(s.CyberConnection, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    local g=Duel.GetMatchingGroup(s.RoidConnection, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    local g=Duel.GetMatchingGroup(s.Steamroid, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    local g=Duel.GetMatchingGroup(s.Drillroid, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

    local g=Duel.GetMatchingGroup(s.Submarineroid, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+5)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    local g=Duel.GetMatchingGroup(s.Horn, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+6)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    local g=Duel.GetMatchingGroup(s.Edge, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+7)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    local g=Duel.GetMatchingGroup(s.Keel, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+8)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    local g=Duel.GetMatchingGroup(s.RoidOriginal, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+9)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

