--Geargiaspring Conscription
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
local ARCHETYPE=0x72

--Tin Archduke, Gearspring Cards, Aye-Iron, Tin Goldfish and Iron Spells
function s.archetypefilter(c)
  return c:IsCode(45458027, 42969214, 18063928, 34559295, 64662453, 511002903, 511002904, 511001762, 511002905, 66506689)
end



function s.RankSumm(_,c)
	return c:GetFlagEffect(id)>0
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

		local e10=Effect.CreateEffect(e:GetHandler())
		e10:SetType(EFFECT_TYPE_FIELD)
		e10:SetCode(EFFECT_XYZ_LEVEL)
		e10:SetTargetRange(LOCATION_MZONE, 0)
		e10:SetTarget(s.RankSumm)
		e10:SetValue(s.xyzlv)
        Duel.RegisterEffect(e10,tp)

		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_SPSUMMON_SUCCESS)
		e8:SetOperation(s.tingoldfishcheck)
		Duel.RegisterEffect(e8,tp)

		local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(511001225)
		e7:SetOperation(s.tgval)
		e7:SetValue(1)
		e7:SetTarget(function (_,c) return c:GetFlagEffect(id)>0 end)
		e7:SetTargetRange(LOCATION_MZONE,0)
		Duel.RegisterEffect(e7,tp)


		local e11=Effect.CreateEffect(e:GetHandler())
		e11:SetType(EFFECT_TYPE_FIELD)
		e11:SetCode(EFFECT_XYZ_LEVEL)
		e11:SetTargetRange(LOCATION_MZONE, 0)
		e11:SetTarget(function (_,c) return c:GetFlagEffect(id)>0 end)
		e11:SetValue(s.xyzlv)
        Duel.RegisterEffect(e11,tp)

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetTargetRange(LOCATION_HAND,0)
		e2:SetTarget(function (_,c) return c:IsLevel(3) and c:IsRace(RACE_MACHINE) end)
		e2:SetCondition(function (e) return Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil, 18063928) end)
		e2:SetValue(4)
        Duel.RegisterEffect(e2,tp)
		

	end
	e:SetLabel(1)
end

function s.tgval(e,c)
	return c:IsCode(66506689)
end


function s.tingoldfishcheck(e,tp,eg,ev,ep,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	if (rc:IsCode(18063928)) and rc:IsType(TYPE_MONSTER) then
		local ec=eg:GetFirst()
		while ec do
			ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
			ec=eg:GetNext()
		end
	end
end


function s.xyzlv(e,c,rc)
	if rc:IsRace(RACE_MACHINE) then
		return 3,4,c:GetLevel()
	else return c:GetLevel()
	end
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

