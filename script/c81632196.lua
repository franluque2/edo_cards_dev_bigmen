--Granel Guard (CT)
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

	--defend with synchro
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
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
	return (not c:IsControler(c:GetOwner())) and c:IsOriginalType(TYPE_MONSTER)
end

function s.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	local bt=eg:GetFirst()
	return Duel.IsExistingMatchingCard(s.otherfilter, tp, LOCATION_SZONE, 0, 1,nil) and bt:IsControler(tp)
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
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)

			if not tc:IsImmuneToEffect(e) then
				Duel.ChangeAttackTarget(tc)
			end

			--Cannot target other monsters for attacks
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			e2:SetRange(LOCATION_MZONE)
			e2:SetTargetRange(0,LOCATION_MZONE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(s.tgtg)
			tc:RegisterEffect(e2)



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

function s.tgtg(e,c)
	return c~=e:GetHandler()
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	local tc=Duel.SelectMatchingCard(tp, s.otherfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
	local c=e:GetHandler()
	if tc then

		Duel.SendtoDeck(c,nil,-2,REASON_EFFECT)

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
		local eqc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,0x3013),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if Duel.Equip(tp,tc,eqc,true) then
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
