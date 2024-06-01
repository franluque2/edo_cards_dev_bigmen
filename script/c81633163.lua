--Hunting Games of Fusion
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

function s.banishpolyfilter(c)
    return c:IsSetCard(0x46) and c:IsAbleToRemoveAsCost()
end

function s.addpolyfilter(c)
    return c:IsSetCard(0x46) and c:IsAbleToHand()
end



function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

    local params={extrafil=s.fextra(nil)}

	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.banishpolyfilter, tp, LOCATION_GRAVE, 0, 1, nil) and Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end

function s.fextra(exc)
	return function(e,tp,mg)
		return nil,s.fcheck(exc)
	end
end
function s.fcheck(exc)
	return function(tp,sg,fc)
		return not (exc and sg:IsContains(exc))
	end
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
	Duel.Hint(HINT_CARD,tp,id)

    Fusion.SummonEffTG()(e,tp,eg,ep,ev,re,r,rp,1)
    Fusion.SummonEffOP()(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.addpolyfilter, tp, LOCATION_DECK, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local tc=Duel.SelectMatchingCard(tp, s.addpolyfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
        Duel.SendtoHand(tc, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, tc)
    end


	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    end
end
