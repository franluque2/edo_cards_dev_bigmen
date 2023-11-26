--Normal Summon Alligator
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


		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		e2:SetCondition(s.flipcon2)
		e2:SetOperation(s.flipop2)
		Duel.RegisterEffect(e2,tp)





	end
	e:SetLabel(1)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end

function s.kunaifilter(c)
	return c:IsCode(37390589) and c:IsAbleToHand()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp, id)==0 and rp==tp and eg:IsExists(Card.IsCode, 1, nil, 64428736) and Duel.IsExistingMatchingCard(s.kunaifilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
	Duel.Hint(HINT_CARD,tp,id)
	local tc=Duel.SelectMatchingCard(tp, s.kunaifilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1,1,false,nil)
	Duel.SendtoHand(tc, tp,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

end
