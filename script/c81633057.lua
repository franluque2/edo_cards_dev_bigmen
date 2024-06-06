--Conscription for Cats
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
  return c:IsSetCard(0x50e)
end


function s.tobecomestraycatfilter(c)
    return c:IsCode(14878871,52346240,8634636,24140059,96501677,93018428,64475743,95841282,70975131,11021521,28981598,84224627)
end

function s.tobecomecatgirlfilter(c)
    return c:IsCode(43352213,1761063,50690129,54191698)
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
        e5:SetTarget(function(_,c)  return s.tobecomecatgirlfilter(c) end)
        e5:SetValue(0x150e)
        Duel.RegisterEffect(e5,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_SETCODE)
        e7:SetTargetRange(LOCATIONS,0)
        e7:SetTarget(function(_,c)  return s.tobecomestraycatfilter(c) end)
        e7:SetValue(0x1538)
        Duel.RegisterEffect(e7,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_RACE)
        e8:SetTargetRange(LOCATIONS,0)
        e8:SetTarget(function(_,c)  return s.tobecomecatgirlfilter(c) or s.tobecomestraycatfilter(c) end)
        e8:SetValue(RACE_BEAST)
        Duel.RegisterEffect(e8,tp)

        local e9=e8:Clone()
        e9:SetCode(EFFECT_ADD_ATTRIBUTE)
        e9:SetValue(ATTRIBUTE_EARTH)
        Duel.RegisterEffect(e9, tp)

        local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetTargetRange(LOCATION_GRAVE,0)
		e6:SetCode(EFFECT_CHANGE_LEVEL)
        e6:SetCondition(s.chgcon)
		e6:SetTarget(s.straycatorcatgirl)
		e6:SetValue(9)
		Duel.RegisterEffect(e6, tp)
    

	end
	e:SetLabel(1)
end


function s.chgcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,28981598), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.straycatorcatgirl(e,c)
    return c:HasLevel() and (s.tobecomecatgirlfilter(c) or s.tobecomestraycatfilter(c))
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

