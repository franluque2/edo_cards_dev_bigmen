--Conscription of the Gatekeeper of Hell
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
local ARCHETYPE=0x54b

--add the conditions for the archetype swap here
function s.BecomeSlimes(c)
  return c:IsCode(15771991, 79387392, 511310112, 511310111, 05600127)
end

function s.Slimes(c)
  return c:IsSlime()
end

function s.Backrow(c)
  return c:IsCode(21770260, 21558682) or (c:IsSlime() and c:IsSpellTrap())
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

        --Select Cards become Slimes
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATIONS,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(ARCHETYPE)
        Duel.RegisterEffect(e5,tp)

        --Slimes become Fiend Slime Mold in deck
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_CODE)
        e6:SetTargetRange(LOCATION_DECK,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e6:SetValue(511000482)
        Duel.RegisterEffect(e6,tp)

        --Slimes become Darkness monsters in GY
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_SETCODE)
        e8:SetTargetRange(LOCATION_GRAVE,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e8:SetValue(0x316)
        Duel.RegisterEffect(e8,tp)


        --Monsters become Revival jam.
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_CHANGE_CODE)
        e4:SetTargetRange(LOCATION_MZONE,0)
        e4:SetCondition(s.changecon)
        e4:SetTarget(function(_,c) return c:IsFaceup() and c:IsLevelBelow(8) end)
        e4:SetValue(31709826)
        Duel.RegisterEffect(e4,tp)


        --cards become Metal Reflect Slime
        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_CODE)
        e7:SetTargetRange(LOCATIONS,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e7:SetValue(26905245)
        Duel.RegisterEffect(e7,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_ADJUST)
		e9:SetCondition(s.removeloccon)
		e9:SetOperation(s.removelocop)
        Duel.RegisterEffect(e9,tp)
    

	end
	e:SetLabel(1)
end


function s.markedfilter(c,e)
    return #c:IsHasEffect(e)>0
end

function s.changecon(e)
    local ph=Duel.GetCurrentPhase()

	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end

function s.removeloccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON)
end
function s.removelocop(e,tp,eg,ep,ev,re,r,rp)
	while Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON) and Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON):GetHandler():IsCode(21770260) do
        local ef=Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON)
        if ef:GetHandler():IsCode(21770260) then
            local ef2=Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_FLIP_SUMMON)
            local ef3=Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SUMMON)
            ef:Reset()
            ef2:Reset()
            ef3:Reset()
        end
	end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(s.BecomeSlimes, tp, LOCATION_ALL, LOCATION_ALL, nil)

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
			
				local e4=Effect.CreateEffect(e:GetHandler())
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(id+2)
				tc:RegisterEffect(e4)


			tc=g:GetNext()
		end
	end
    
    g=Duel.GetMatchingGroup(s.Slimes, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e4=Effect.CreateEffect(e:GetHandler())
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(id+1)
				tc:RegisterEffect(e4)


			tc=g:GetNext()
		end
	end

    local Humanoid=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 05600127)
    if #Humanoid>0 then
        local tc=Humanoid:GetFirst()
            while tc do
        
                    Fusion.AddProcMixN(tc, true, true, s.Slimes, 2)
    
    
                tc=Humanoid:GetNext()
            end
    end
    

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

