--The Three Despairs
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

function s.returnablemon(c)
    return c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.locfilter(c,e,tp)
    return c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.returnablemon, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
	Duel.Hint(HINT_CARD,tp,id)
    local tc=Duel.SelectMatchingCard(tp, s.returnablemon, tp, LOCATION_MZONE, LOCATION_MZONE, 1,1,false,nil):GetFirst()

    local mg=tc:GetMaterial():Filter(s.locfilter,nil,e,tp)
	local ct=#mg

    local tpmat=Group.Filter(mg, Card.IsControler, nil, tp)
    local nontpmat=Group.Filter(mg, Card.IsControler, nil, 1-tp)

	if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0
		and ct>0
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
        then
		Duel.BreakEffect()
        if tpmat then
            Duel.SpecialSummon(tpmat,0,tp,tp,false,false,POS_FACEUP)
        end

        if nontpmat then
            Duel.SpecialSummon(nontpmat,0,tp,1-tp,false,false,POS_FACEUP)
        end
	end


	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)


	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    end
end

function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
