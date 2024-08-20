--Tag Duels are Dumb and they need a Filler
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetLabel(0)
    e1:SetRange(LOCATION_ALL)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

end



function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		
        Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)

        if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
            Duel.Draw(tp, 1, REASON_EFFECT)
        end

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
        e1:SetCountLimit(1,id)
		Duel.RegisterEffect(e1,tp)

	end
	e:SetLabel(1)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_ALL, 0, 1, nil, TYPE_SKILL)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_ALL, 0, nil, TYPE_SKILL)
	local cardsinhand=g:Filter(Card.IsLocation, nil, LOCATION_HAND)
	local num=0
	if cardsinhand then
		num=#cardsinhand
	end
	if g then
		Duel.RemoveCards(g)
	end
	Duel.Draw(tp, num, REASON_RULE)

end