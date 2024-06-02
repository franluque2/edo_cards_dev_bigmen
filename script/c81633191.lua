--Quantum Cube
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


        local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e3:SetCountLimit(1)
		e3:SetCondition(s.spcon)
		e3:SetOperation(s.spop)
		Duel.RegisterEffect(e3,tp)




	end
	e:SetLabel(1)
end

function s.remmonfilter(c)
    return c:IsAbleToRemoveAsCost()
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==1 and Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(s.remmonfilter, tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.IsPlayerCanSpecialSummonMonster(tp, CARD_VIJAM, 0xe3, TYPE_EFFECT, 0, 0, 1, RACE_FIEND, ATTRIBUTE_DARK)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
		Duel.Hint(HINT_CARD,tp,id)

		local tc=Duel.SelectMatchingCard(tp, s.remmonfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil)
		if tc then
			local rc=tc:GetFirst()
			if Duel.Remove(rc,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(rc)
				e1:SetCountLimit(1)
				e1:SetOperation(s.retop)
				Duel.RegisterEffect(e1,tp)

				local vijam=Duel.CreateToken(tp, CARD_VIJAM)
				Duel.SpecialSummon(vijam, SUMMON_TYPE_SPECIAL, tp, tp, false,false , POS_FACEDOWN_DEFENSE)

				local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
				for tc in sg:Iter() do
					local e2=Effect.CreateEffect(e:GetHandler())
					e2:SetDescription(3200)
					e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_MUST_ATTACK)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e2)
				end
			end
		end

		Duel.RegisterFlagEffect(tp,id,0,0,0)

	end
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
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
