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
function s.MonstersBecomeMemento(c)
  return c:IsType(TYPE_MONSTER) and (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_DRAGON))
end

function s.SpellsTrapsBecomeMemento(c)
  return c:IsSpellTrap()
end

function s.BecomeDarkBlade(c)
  return c:IsCode(810000093, 18165869, 86805855)
end

function s.ThunderNyanNyan(c)
  return c:IsCode(70797118)
end

function s.Kiryu(c)
  return c:IsCode(84814897)
end

function s.BecomeDragons(c)
  return c:IsCode(810000093, 25131968, 86805855)
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
        e5:SetValue(SET_MEMENTO)
        Duel.RegisterEffect(e5,tp)

		local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e6:SetValue(ATTRIBUTE_LIGHT)
        Duel.RegisterEffect(e6,tp)

		local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_SETCODE)
        e7:SetTargetRange(LOCATIONS,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e7:SetValue(SET_MEMENTO)
        Duel.RegisterEffect(e7,tp)

		local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_CODE)
        e8:SetTargetRange(LOCATIONS,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e8:SetValue(11321183)
        Duel.RegisterEffect(e8,tp)

		local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_CHANGE_RACE)
        e9:SetTargetRange(LOCATIONS,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id+3) end)
        e9:SetValue(RACE_WARRIOR)
        Duel.RegisterEffect(e9,tp)

		local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_CHANGE_LEVEL)
        e10:SetTargetRange(LOCATION_HAND+LOCATION_DECK,0)
        e10:SetTarget(function(_,c)  return c:IsHasEffect(id+4) end)
        e10:SetValue(3)
        Duel.RegisterEffect(e10,tp)

		local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_ADD_RACE)
        e11:SetTargetRange(LOCATION_GRAVE,0)
        e11:SetTarget(function(_,c)  return c:IsHasEffect(id+5) end)
        e11:SetValue(RACE_DRAGON)
        Duel.RegisterEffect(e11,tp)
    

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

    local g=Duel.GetMatchingGroup(s.MonstersBecomeMemento, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

	g=Duel.GetMatchingGroup(s.SpellsTrapsBecomeMemento, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

	g=Duel.GetMatchingGroup(s.BecomeDarkBlade, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

	g=Duel.GetMatchingGroup(s.ThunderNyanNyan, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

	g=Duel.GetMatchingGroup(s.Kiryu, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

	g=Duel.GetMatchingGroup(s.BecomeDragons, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

	local Sun=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 86805855)
    if #Sun>0 then
	local tc=Sun:GetFirst()
		while tc do
	
            Fusion.AddProcMix(tc,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR),aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON))


			tc=Sun:GetNext()
		end
    end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
