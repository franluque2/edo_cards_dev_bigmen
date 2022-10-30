--Dark Butter (CT)
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetOwner()~=e:GetHandlerPlayer()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp, 3)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute, ATTRIBUTE_DARK), tp, LOCATION_MZONE, 0, 1,nil) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp, 3)
	g=g:Filter(Card.IsType, nil, TYPE_MONSTER)

	if Duel.DiscardDeck(tp, 3, REASON_EFFECT)>0 then
		g=g:Filter(Card.IsLocation, nil, LOCATION_GRAVE)

		if #g>0 then
			local tc=Duel.SelectMatchingCard(tp, aux.FaceupFilter(Card.IsAttribute, ATTRIBUTE_DARK), tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
			if tc then
				local val=(#g)*500
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e1:SetValue(val)
				tc:RegisterEffect(e1)
			end
		end
	end
end
