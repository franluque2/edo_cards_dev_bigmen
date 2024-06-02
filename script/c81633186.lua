--A Glimpse of a Clear World
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
		e2:SetCode(EVENT_PHASE+PHASE_DRAW)
		e2:SetCondition(s.actcon)
        e2:SetCountLimit(1)
		e2:SetOperation(s.actop)
		Duel.RegisterEffect(e2,tp)

	end
	e:SetLabel(1)
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp, id)==1 and Duel.GetTurnPlayer()~=tp
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
        Duel.Hint(HINT_CARD,tp,id)

        local cworld=Duel.CreateToken(tp, CARD_CLEAR_WORLD)
        Duel.ActivateFieldSpell(cworld,e,tp,eg,ep,ev,re,r,rp)

        aux.DelayedOperation(cworld,PHASE_END,id,e,tp,function(ag) Duel.Remove(ag, POS_FACEUP, REASON_EFFECT) end,nil,0)

    
        Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    
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
