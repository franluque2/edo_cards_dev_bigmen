--Future Visions
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

	if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, 1,nil, 77565204) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler(),REASON_EFFECT)
	 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		 Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
		 local discard=Duel.SelectMatchingCard(tp, Card.IsDiscardable, tp, LOCATION_HAND, 0, 1,1,false,nil)
		 if Duel.SendtoGrave(discard, REASON_DISCARD) then
			 local futurefusion=Duel.GetFirstMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, nil, 77565204)

			 local tc=futurefusion

		 		local tpe=tc:GetType()
		 		local te=tc:GetActivateEffect()
		 		if te then
		 			local con=te:GetCondition()
		 			local co=te:GetCost()
		 			local tg=te:GetTarget()
		 			local op=te:GetOperation()
		 			Duel.ClearTargetCard()
		 			e:SetCategory(te:GetCategory())
		 			e:SetProperty(te:GetProperty())
		 			if tpe&TYPE_FIELD~=0 then
		 				local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		 				if Duel.IsDuelType(DUEL_1_FIELD) then
		 					if fc then Duel.Destroy(fc,REASON_RULE) end
		 					fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		 					if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		 				else
		 					fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		 					if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		 				end
		 			end
		 			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		 			Duel.Hint(HINT_CARD,0,tc:GetCode())
		 			tc:CreateEffectRelation(te)
		 			if tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD==0 then
		 				tc:CancelToGrave(false)
		 			end
		 			if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
		 			if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end

		 			Duel.BreakEffect()
		 			if op then op(te,tp,eg,ep,ev,re,r,rp) end
		 			tc:ReleaseEffectRelation(te)

				end


		 end
	 end
end
