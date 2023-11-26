--Kingdoms Dungeon Runner
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

	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)

end



function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id, 0))
		local dex=Duel.AnnounceNumberRange(tp,0,100)
		--register dex for other skills
		if dex>0 then
			for i= 0,dex, 1
				do
				  Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
				end

				if (dex//5>0) then
					Duel.Draw(tp, dex//5, REASON_EFFECT)
				end



		end

		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id, 1))
		local con=Duel.AnnounceNumberRange(tp,0,100)
		--register con for other skills
		if con>0 then
			for i= 0,con, 1
				do
				  Duel.RegisterFlagEffect(tp, id+1, 0, 0, 0)
				end

		--con lp increase
		Duel.Recover(tp, con*1200, REASON_EFFECT)

		end

		Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id, 2))
		local str=Duel.AnnounceNumberRange(tp,0,100)

		--register str for other skills
		if str>0 then
			for i= 0,str, 1
				do
				  Duel.RegisterFlagEffect(tp, id+2, 0, 0, 0)
				end


		end



	end
	e:SetLabel(1)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end


--STR attack/def gain
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id+3)>0  then return end

	--no activate if no str
	if Duel.GetFlagEffect(tp, id+2)==0 then return end


	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, nil)

	return aux.CanActivateSkill(tp) and b1
end

function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local monster=Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, false, nil)
	if monster then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(Duel.GetFlagEffect(tp, id+2)*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		monster:GetFirst():RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		monster:GetFirst():RegisterEffect(e2)
		Duel.RegisterFlagEffect(tp, id+3, 0, 0, 0)
	end

end
