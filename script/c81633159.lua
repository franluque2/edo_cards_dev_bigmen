--Duel Academy's Defence Force!
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
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


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end

    local duelac=Duel.CreateToken(tp, 05833312)
	for _,eff in ipairs({duelac:GetCardEffect(EVENT_CHAIN_SOLVED)}) do

		if eff:GetCategory()&CATEGORY_DESTROY==CATEGORY_DESTROY then
			eff:SetCondition(s.descon)
		end
		if eff:GetCategory()&CATEGORY_DAMAGE==CATEGORY_DAMAGE then
			eff:SetCondition(s.damcon)
		end
		if eff:GetCategory()&CATEGORY_ATKCHANGE==CATEGORY_ATKCHANGE then
			eff:SetCondition(s.atkcon)
		end
	end

    Duel.SendtoHand(duelac, tp, REASON_RULE)

	local poly=Duel.CreateToken(tp, CARD_POLYMERIZATION)
    Duel.SendtoHand(poly, tp, REASON_RULE)

end


function s.typecheck(types,tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,types),0,LOCATION_MZONE,LOCATION_MZONE,1,nil) or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_FUSION),tp,LOCATION_MZONE,0,1,nil)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return s.typecheck(RACE_WARRIOR|RACE_BEAST|RACE_PYRO,tp) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and rp==tp
		and not e:GetHandler():IsDisabled()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return s.typecheck(RACE_MACHINE|RACE_FAIRY|RACE_FIEND,tp) and re:IsActiveType(TYPE_MONSTER) and rp==tp
		and not e:GetHandler():IsDisabled()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return s.typecheck(RACE_DINOSAUR|RACE_SEASERPENT|RACE_THUNDER,tp) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and rp==tp
		and re:GetHandler()~=c and not c:IsDisabled()
end