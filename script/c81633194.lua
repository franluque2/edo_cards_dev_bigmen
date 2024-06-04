--The Millennium Key
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
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,nil)


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

function s.remmonfilter(c)
    return c:IsMonster() and c:IsAbleToRemoveAsCost()
end

function s.spsumfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, true, true,POS_FACEUP)
 end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.remmonfilter, tp, LOCATION_GRAVE, 0, 5, nil) and Duel.IsExistingMatchingCard(s.spsumfilter, tp, LOCATION_DECK|LOCATION_EXTRA, 0, 1, nil,e,tp)  and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
	Duel.Hint(HINT_CARD,tp,id)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local torem=Duel.SelectMatchingCard(tp, s.remmonfilter, tp, LOCATION_GRAVE, 0, 5,5,false,nil)
    if torem then
        Duel.Remove(torem, POS_FACEUP, REASON_COST)
    end

    if Duel.GetFlagEffect(1-tp, 81633193)>0 then
        Duel.Hint(HINT_CARD,tp,81633193)
        Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

        return
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)

    local tosum=Duel.SelectMatchingCard(tp, s.spsumfilter, tp, LOCATION_DECK|LOCATION_EXTRA, 0, 1,1,false,nil,e,tp)
    if tosum then
        local tc=tosum:GetFirst()
        Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, true,true, POS_FACEUP)
        local fid=e:GetHandler():GetFieldID()


        tc:RegisterFlagEffect(id,RESET_EVENT|RESET_MSCHANGE|RESET_OVERLAY|RESET_TURN_SET|RESET_PHASE|PHASE_END,0,1,fid)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetOperation(s.leaveop)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
    end




	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    end
end

function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if eg:IsContains(tc) and tc:GetFlagEffectLabel(id)==e:GetLabel() then
		local p=tc:GetPreviousControler()
        local atk=tc:GetBaseAttack()
        local def=tc:GetBaseDefense()
        if def>atk then
            atk=def
        end
		if Duel.Damage(p,atk,REASON_EFFECT)>0 then
			Duel.Hint(HINT_CARD,0,id)
		end
		tc:ResetFlagEffect(id)
		e:Reset()
	end
end