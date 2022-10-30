--Granel Attack (CT)
local s,id=GetID()
function s.initial_effect(c)

	c:SetUniqueOnField(1,0,c:Alias())

	--selfdes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(s.sdcon)
	c:RegisterEffect(e1)

	--attack with synchro
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.ctlcon)
	e2:SetTarget(s.ctltg)
	e2:SetOperation(s.ctlop)
	c:RegisterEffect(e2)

end
s.listed_series={0x3013}
function s.sdcon(e)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x3013),0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.otherfilter(c)
	return (not c:IsControler(c:GetOwner())) and c:CanAttack()
end

function s.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.otherfilter, tp, LOCATION_SZONE, 0, 1,nil)
end

function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.otherfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.otherfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.otherfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.SendtoDeck(c,nil,-2,REASON_EFFECT)
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP_ATTACK)
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)

			if tc:CanAttack() and not tc:IsImmuneToEffect(e) then
				local ats=tc:GetAttackableTarget()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
				if #ats>0 then
					local g=ats:Select(tp,1,1,nil)
					Duel.CalculateDamage(tc,g:GetFirst())

					local e2=Effect.CreateEffect(e:GetHandler())
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_CANNOT_ATTACK)
					e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
					tc:RegisterEffect(e2,true)
				end
			end


		local e3=Effect.CreateEffect(c)
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e3:SetCountLimit(1)
		e3:SetRange(LOCATION_SZONE)
		e3:SetOperation(s.rmop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)


	end
end

function s.otherfilter2(c)
	return (not c:IsControler(c:GetOwner()))
end


function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	local tc=Duel.SelectMatchingCard(tp, s.otherfilter2, tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
	local c=e:GetHandler()
	if tc then

		Duel.SendtoDeck(c,nil,-2,REASON_EFFECT)

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
		local eqc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,0x3013),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if eqc and Duel.Equip(tp,tc,eqc,true) then
			--add equip limit
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(true)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end

		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)

	else
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
