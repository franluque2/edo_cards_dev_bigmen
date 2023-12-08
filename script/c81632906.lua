--Chosen by the Legendary Planet
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
		aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
end
local planets={24413299,74711057,88071625,15033525,34004470,51402908,03912064,05645210,16255173,32588805}

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.flipcon)
	e1:SetOperation(s.flipop)
	Duel.RegisterEffect(e1,tp)

	--other passive duel effects go here

	--adrian
	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ADD_RACE)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
	e5:SetValue(RACE_REPTILE)
	Duel.RegisterEffect(e5,tp)

	local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_ADD_RACE)
	e6:SetTargetRange(LOCATION_GRAVE+LOCATION_ONFIELD,0)
	e6:SetCondition(function(e,tp) return Duel.IsPlayerAffectedByEffect(e:GetHandler():GetControler(),511000380) end)
	e6:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
	e6:SetValue(RACE_BEAST)
	Duel.RegisterEffect(e6,tp)

	--axel
	local eaxel1=Effect.CreateEffect(e:GetHandler())
	eaxel1:SetType(EFFECT_TYPE_FIELD)
	eaxel1:SetCode(EFFECT_ADD_SETCODE)
	eaxel1:SetTargetRange(LOCATION_ALL,0)
	eaxel1:SetCondition(function(_,pl) return Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandler():GetControler(), LOCATION_ALL, 0, 1, nil, 15033525) end)
	eaxel1:SetTarget(function(_,c)  return c:IsRace(RACE_MACHINE) end)
	eaxel1:SetValue(SET_RESCUE_ACE)
	Duel.RegisterEffect(eaxel1,tp)

	local eaxel2=Effect.CreateEffect(e:GetHandler())
	eaxel2:SetType(EFFECT_TYPE_FIELD)
	eaxel2:SetCode(EFFECT_ADD_SETCODE)
	eaxel2:SetTargetRange(LOCATION_ALL,0)
	eaxel2:SetCondition(function(_,pl) return Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandler():GetControler(), LOCATION_ALL, 0, 1, nil, 15033525) end)
	eaxel2:SetTarget(function(_,c)  return c:IsOriginalCode(100304006,511002337,511002338) end)
	eaxel2:SetValue(SET_RESCUE_ACE)
	Duel.RegisterEffect(eaxel2,tp)

	local eaxel3=Effect.CreateEffect(e:GetHandler())
	eaxel3:SetType(EFFECT_TYPE_FIELD)
	eaxel3:SetCode(EFFECT_ADD_RACE)
	eaxel3:SetTargetRange(LOCATION_ALL,0)
	eaxel3:SetCondition(function(_,pl) return Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandler():GetControler(), LOCATION_ALL, 0, 1, nil, 15033525) end)
	eaxel3:SetTarget(function(_,c)  return c:IsOriginalCode(41443249) end)
	eaxel3:SetValue(RACE_PYRO)
	Duel.RegisterEffect(eaxel3,tp)

	local eaxel4=Effect.CreateEffect(e:GetHandler())
	eaxel4:SetType(EFFECT_TYPE_FIELD)
	eaxel4:SetCode(EFFECT_DISABLE)
	eaxel4:SetTargetRange(LOCATION_MZONE,0)
	eaxel4:SetCondition(function(_,pl) return Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandler():GetControler(), LOCATION_ALL, 0, 1, nil, 15033525) and not (Duel.GetTurnPlayer()==e:GetHandler():GetControler() and Duel.IsMainPhase()) end)
	eaxel4:SetTarget(function(_,c)  return c:IsOriginalCode(41443249) end)
	Duel.RegisterEffect(eaxel4,tp)

	end
	e:SetLabel(1)
end

function s.flipconfilter(c)
	return c:IsFaceup() and s.has_value(planets,c:GetOriginalCode())
end

function s.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToGrave()
end

function s.planetfilter(c)
return s.has_value(planets,c:GetOriginalCode()) and Duel.IsExistingMatchingCard(s.thfilter,c:GetOwner(),LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,c,c:GetOriginalCode())
end

function s.has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

function s.flipcon2filter(c)
	return s.has_value(planets,c:GetOriginalCode())
end

--add the conditions for the archetype swap here
function s.archetypefilterforbbeast(c)
  return c:IsSetCard(0x51e) 
  and c:IsType(TYPE_MONSTER)
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--"cost" check
	return  Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and (Duel.IsExistingMatchingCard(s.flipcon2filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil))
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)

	local g=Duel.GetMatchingGroup(s.archetypefilterforbbeast, tp, LOCATION_ALL, LOCATION_ALL, nil)

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

end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(tp,id)==0 then return end
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 then return end
	--condition
	local b1=Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(s.flipconfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	local b2=Duel.GetFlagEffect(tp,id+2)==0 and Duel.IsExistingMatchingCard(s.planetfilter,tp,LOCATION_GRAVE,0,1,nil,tp)

	return aux.CanActivateSkill(tp) and (b1 or b2)
end

function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

function s.idfilter(c,code)
	return c:GetOriginalCode()==code
end

function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler(e)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local b1=Duel.GetFlagEffect(ep,id+1)==0 and Duel.IsExistingMatchingCard(s.flipconfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	local b2=Duel.GetFlagEffect(ep,id+2)==0 and Duel.IsExistingMatchingCard(s.planetfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	if (b2 and b1) then
		p=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		p=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		p=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if p==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.flipconfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local cards=Duel.GetMatchingGroup(s.idfilter,tp,LOCATION_MZONE,0,0,g:GetOriginalCode())
	if g then
		for tc in aux.Next(cards) do
		--Unaffected by opponent's card effects
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(3110)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(s.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e3:SetOwnerPlayer(tp)
		tc:RegisterEffect(e3)
		end
	end
		--opd register
		Duel.RegisterFlagEffect(tp,id+1,0,0,0)
	else
		local tc=Duel.SelectMatchingCard(tp,s.planetfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,tc:GetOriginalCode())
		if #sg>0 then
			if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
		end
		--opt register
		Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)

	end
end
