--Mimicry Protocols
local s,id=GetID()


function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,1,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
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
		e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)


		local c=e:GetHandler()

		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
		e2:SetValue(s.indes)

		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetTarget(aux.TRUE)
		e3:SetLabelObject(e2)
		Duel.RegisterEffect(e3,tp)
end
e:SetLabel(1)
end

	function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
	end

	function s.flipop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		s.copyhand(e,tp,eg,ep,ev,re,r,rp)
		s.copyextra(e,tp,eg,ep,ev,re,r,rp)
		s.copydeck(e,tp,eg,ep,ev,re,r,rp)
	end


	function s.indes(e,c)
		return c:IsCode(e:GetHandler():GetCode())
	end


function s.copyhand(e,tp,eg,ep,ev,re,r,rp)
		local location=LOCATION_HAND
		local to_limbo=Duel.GetMatchingGroup(aux.TRUE, tp, location, 0, nil)
		Duel.RemoveCards(to_limbo)

		local oppcards=Duel.GetMatchingGroup(aux.TRUE, tp, 0, location, nil)

		if #oppcards>0 then
			local tc=oppcards:GetFirst()
			local newcard=nil
			while tc do

				newcard=Duel.CreateToken(tp, tc:GetOriginalCode())
				Duel.SendtoHand(newcard, tp, REASON_EFFECT)


				tc=oppcards:GetNext()
			end

		end


end

function s.copyextra(e,tp,eg,ep,ev,re,r,rp)
		local location=LOCATION_EXTRA
		local to_limbo=Duel.GetMatchingGroup(aux.TRUE, tp, location, 0, nil)
		Duel.RemoveCards(to_limbo)

		local oppcards=Duel.GetMatchingGroup(aux.TRUE, tp, 0, location, nil)

		if #oppcards>0 then
			local tc=oppcards:GetFirst()
			local newcard=nil
			while tc do

				newcard=Duel.CreateToken(tp, tc:GetOriginalCode())
				Duel.SendtoDeck(newcard, tp, SEQ_DECKTOP, REASON_EFFECT)

				tc=oppcards:GetNext()
			end

		end


end


function s.copydeck(e,tp,eg,ep,ev,re,r,rp)
		local location=LOCATION_DECK
		local to_limbo=Duel.GetMatchingGroup(aux.TRUE, tp, location, 0, nil)
		Duel.DisableShuffleCheck(true)
		Duel.RemoveCards(to_limbo)

		local oppcardnum=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		local oppcards=Duel.GetDecktopGroup(1-tp, oppcardnum)

		if #oppcards>0 then
			local tc=oppcards:GetFirst()
			local newcard=nil
			while tc do

				newcard=Duel.CreateToken(tp, tc:GetOriginalCode())
				Duel.SendtoDeck(newcard, tp, SEQ_DECKTOP, REASON_EFFECT)

				tc=oppcards:GetNext()
			end

		end

		Duel.DisableShuffleCheck(false)
end
