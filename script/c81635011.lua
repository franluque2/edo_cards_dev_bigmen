--When you really think about it Pochita is just a Frightfur monster
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



local cardstosend={39246582,66457138, 13241004, 82896870, 3841833, 65331686, 45215225, 98280324, 87246309, 2729285, 38124994, 6142488,
 72413000, 81481818, 73240432, 97567736, 34566435, 61173621, 30068120, 29280589, 34688023, 77522571, 58468105, 78778375, 91034681,
  83866861, 80889750, 40636712, 10383554, 85545073, 11039171, 464362, 57477163}

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here
	s.placeonfield(70245411,tp)
	s.placeonfield(70245411,tp)
	s.placeonfield(70245411,tp)

	for k,v in pairs(cardstosend) do
		s.sendtograve(v,tp)
	 end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.placeonfield(code,tp)
	local token=Duel.CreateToken(tp, code)
	Duel.MoveToField(token, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
end

function s.sendtograve(code,tp)
	local token=Duel.CreateToken(tp, code)
	Duel.SendtoGrave(token, REASON_RULE)
	local token=Duel.CreateToken(tp, code)
	Duel.SendtoGrave(token, REASON_RULE)
	local token=Duel.CreateToken(tp, code)
	Duel.SendtoGrave(token, REASON_RULE)
end
