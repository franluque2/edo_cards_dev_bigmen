--Card Vendor
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
	if Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, 1,nil, 48712195) then
			 local cardvendor=Duel.SelectMatchingCard(tp,Card.IsCode, tp, LOCATION_DECK, 0,0,3, nil, 48712195)
			 if #cardvendor~=0 then
			 local tc=cardvendor:GetFirst()

			 while tc do
				 local e2=Effect.CreateEffect(e:GetHandler())
				 	e2:SetDescription(aux.Stringid(48712195,0))
				 	e2:SetCategory(CATEGORY_DRAW)
				 	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				 	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
				 	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
				 	e2:SetRange(LOCATION_SZONE)
				 	e2:SetCountLimit(1)
				 	e2:SetCondition(s.drcon)
				 	e2:SetCost(s.drcost)
				 	e2:SetTarget(s.drtg)
				 	e2:SetOperation(s.drop)
				 	tc:RegisterEffect(e2)



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
				tc=cardvendor:GetNext()
			end


	 end
 end
end


function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
