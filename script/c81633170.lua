--Link VRAINS Generative DLC
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
end



function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

	return aux.CanActivateSkill(tp) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsPlayerCanSpecialSummonMonster(tp,93104633,0,TYPES_TOKEN,2000,2000,4,RACE_CYBERSE,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE)
    and Duel.IsExistingMatchingCard(Card.IsMonster, tp, LOCATION_EXTRA, 0, 1, nil) and Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
	Duel.Hint(HINT_CARD,tp,id)

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local torev=Duel.SelectMatchingCard(tp, Card.IsMonster, tp, LOCATION_EXTRA, 0, 1,1,false,nil)
	if torev then
		Duel.ConfirmCards(1-tp, torev)
		local tc=torev:GetFirst()
		local token=Duel.CreateToken(tp,93104633)

		
		local e11=Effect.CreateEffect(e:GetHandler())
		e11:SetType(EFFECT_TYPE_FIELD)
		e11:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e11:SetCode(EFFECT_CANNOT_SUMMON)
		e11:SetTargetRange(1,0)
		e11:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e11,tp)


		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(tc:GetOriginalRace())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(tc:GetOriginalAttribute())
		token:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_CODE)
		e3:SetValue(tc:GetOriginalCode())
		token:RegisterEffect(e3,true)

	end


	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    end
end
