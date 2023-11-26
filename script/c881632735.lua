--Tapped Potential
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

function s.fscorpionfilter(c)
	return c:IsCode(26566878) and c:IsReleasableByEffect()
end

function s.mscorpionfilter(c,e,tp)
	return c:IsCode(82482194) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>0  then return end

	local b1=Duel.IsExistingMatchingCard(s.fscorpionfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.mscorpionfilter, tp, LOCATION_DECK, 0, 1,nil,e,tp)

	return aux.CanActivateSkill(tp) and b1
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local tc=Duel.SelectMatchingCard(tp, s.fscorpionfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil)

	if Duel.Release(tc, REASON_EFFECT) then
		local scorp=Duel.GetFirstMatchingCard(s.mscorpionfilter, tp, LOCATION_DECK, 0, nil,e,tp)
		if scorp then
			Duel.SpecialSummon(scorp, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
			Duel.RegisterFlagEffect(tp,id,0,0,0)

		end
	end
end

function s.redfunc(c)
	return c:IsCode(82482194)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end

	if Duel.IsExistingMatchingCard(s.redfunc, tp, LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE, 0, 1,nil) then
			 local scorpions=Duel.GetMatchingGroup(s.redfunc, tp, LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE, 0, nil)
			 if #scorpions~=0 then
			 local tc=scorpions:GetFirst()

			 while tc do

				 local e1=Effect.CreateEffect(e:GetHandler())
				 e1:SetDescription(aux.Stringid(82482194,0))
				 e1:SetCategory(CATEGORY_ATKCHANGE)
				 e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
				 e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
				 e1:SetCode(EVENT_BATTLE_DESTROYED)
				 e1:SetRange(LOCATION_MZONE)
				 e1:SetCondition(s.atcon)
				 e1:SetOperation(s.atop)
				 tc:RegisterEffect(e1)

				tc=scorpions:GetNext()
			end


	 end
 end
end

function s.filter(c,rc)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:GetReasonCard()==rc
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,e:GetHandler())
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
