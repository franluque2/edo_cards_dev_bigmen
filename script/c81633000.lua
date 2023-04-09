--Conscription of the Sky God's Servants
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

--Infinite cards, cards of safe return, jam breeding machine, jam defender
function s.archetypefilter3(c)
    return c:IsCode(21770260, 57953380, 94163677, 21558682)
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

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

    local g=Duel.GetMatchingGroup(s.archetypefilter3, tp, LOCATION_ALL, LOCATION_ALL, nil)

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
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
