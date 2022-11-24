--Memory Unlock
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
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


	end
	e:SetLabel(1)
end


--change this to change the locations where this acts
local LOCATIONS=LOCATION_ALL-LOCATION_OVERLAY

--add archetype setcode here
local ARCHETYPE=0x505

--"All "Numbers Evail" in your possession are treated as "Astral" cards"
function s.archetypefilter(c)
  return c:IsCode(20994205)
end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

    s.floodgatenonutopias(e,tp)

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCondition(s.flipcon2)
	e1:SetOperation(s.flipop2)
	Duel.RegisterEffect(e1,tp)

    local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetTargetRange(1,0)
	e6:SetTarget(s.splimit)
	Duel.RegisterEffect(e6,tp)

	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ADD_SETCODE)
	e5:SetTargetRange(LOCATIONS,0)
	e5:SetTarget(function(_,c)  return s.archetypefilter(c) end)
	e5:SetValue(ARCHETYPE)
	Duel.RegisterEffect(e5,tp)


	Duel.RegisterFlagEffect(ep,id,0,0,0)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsHasEffect(id) and not se:GetHandler():IsCode(23187256)
end


function s.notutopiafilter(c)
    return not c:IsSetCard(0x107f)
end

function s.floodgatenonutopias(e,tp)
        local g=Duel.GetMatchingGroup(s.notutopiafilter,tp,LOCATION_EXTRA,0,nil)

        local tc=g:GetFirst()
		while tc do
            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(id)
            tc:RegisterEffect(e3)

			tc=g:GetNext()
		end
end
function s.atohand(code,tp)
	local token=Duel.CreateToken(tp, code)
	Duel.SendtoHand(token, tp, REASON_RULE)
end


local numbers={26556950, 51543904, 49032236, 58820923, 1992816, 97403510, 73445448, 31801517, 89516305, 48995978, 
2978414, 28400508, 63767246, 75433814, 8165596, 23085002, 66547759, 88120966, 95474755, 16037007, 92015800, 80117527,
 53701457, 82308875, 10389142, 64554883, 9161357, 75253697, 93713837, 57707471, 21313376, 29669359, 19333131, 39139935,
  36076683, 62070231, 35772782, 55067058, 23998625, 90126061, 42421606, 65676461, 37279508, 2407234, 76067258, 11411223,
   84417082, 47387961, 46871387, 80796456, 71921856, 23649496, 8387138, 51735257, 50260683, 55470553, 31437713, 80764541,
    66011101, 93108839, 53244294, 7194917, 93568288, 81330115, 56292140, 31320433, 69610924, 47805931, 1426714, 39622156,
     16259549, 32003338, 59479050, 29208536, 54191698, 3790062, 39972129, 55727845, 56051086, 55935416, 48928529, 69058960,
      95442074, 54366836, 89642993, 29085954}

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+1)==0
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_CARD,tp,id)
	local num1=Duel.GetRandomNumber(1, #numbers )
	local num2=Duel.GetRandomNumber(1, #numbers )
	while num2==num1 do
		num2=Duel.GetRandomNumber(1, #numbers )
	end
	local num3=Duel.GetRandomNumber(1, #numbers )
	while num3==num2 or num3==num1 do
		num3=Duel.GetRandomNumber(1, #numbers )
	end

	local option1=Duel.CreateToken(tp, numbers[num1])
	local option2=Duel.CreateToken(tp, numbers[num2])
	local option3=Duel.CreateToken(tp, numbers[num3])

	local g=Group.CreateGroup()
	g:AddCard(option1)
	g:AddCard(option2)
	g:AddCard(option3)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local card=g:Select(tp, 1, 1,nil):GetFirst()

	Xyz.AddProcedure(card,nil,4,2)
	
    Duel.SendtoDeck(card, tp, LOCATION_EXTRA, REASON_RULE)


	Duel.RegisterFlagEffect(ep,id+1,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

