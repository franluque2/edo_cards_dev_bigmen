--The Infinity Circuit
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

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_BATTLED)
        e2:SetCondition(s.batcon)
        e2:SetOperation(s.batadd)
        e2:SetLabel(0)
        Duel.RegisterEffect(e2, tp)





	end
	e:SetLabel(1)
end

function s.adspellfilter(c)
    return c:IsSpell() and c:IsAbleToHand()
end

function s.batcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.adspellfilter, tp, LOCATION_DECK, 0, 1, nil)
end
function s.batadd(e,tp,eg,ep,ev,re,r,rp)
    local num=e:GetLabel()
    local atk=Duel.GetAttacker()
    local def=Duel.GetAttackTarget()
    if atk then
        num=num+1
    end
    if def then
        num=num+1
    end
    if num>=4 then
        num=num-4

        Duel.Hint(HINT_CARD, tp, id)
        local g=Duel.GetMatchingGroup(s.adspellfilter, tp, LOCATION_DECK, 0, nil)
        if g then
            local tc=g:RandomSelect(tp, 1, nil)
            Duel.SendtoHand(tc, tp, REASON_EFFECT)
            Duel.ConfirmCards(1-tp, tc)
        end
    end
    e:SetLabel(num)
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
