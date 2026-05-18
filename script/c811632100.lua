--Charge of the Locals Brigade
local s,id=GetID()
function s.initial_effect(c)
	local e1 = Effect.CreateEffect(c)
        e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_STARTUP)
        e1:SetCountLimit(1, {id, 98})
        e1:SetLabel(0)
        e1:SetRange(LOCATION_ALL)
        e1:SetOperation(s.activateop)

        local e2=e1:Clone()
        e2:SetCode(EVENT_ADJUST)
        c:RegisterEffect(e1)
        c:RegisterEffect(e2)
end

function s.activateop(e, tp, eg, ep, ev, re, r, rp)
            if e:GetLabel() == 0 then
                Duel.DisableShuffleCheck()
                Duel.Hint(HINT_CARD, tp, id)
                Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
                if e:GetHandler():GetPreviousLocation() == LOCATION_HAND then
                    Duel.Draw(tp, 1, REASON_EFFECT)
                end
                if Duel.GetFlagEffect(tp, id)>0 then return end
                Duel.Hint(HINT_SKILL_COVER, tp, id|(300000000 << 32))
                Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
                local e1 = Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
                e1:SetCode(EVENT_FREE_CHAIN)
                e1:SetProperty(EFFECT_FLAG_DELAY)
                e1:SetCondition(s.flipconactive)
                e1:SetOperation(s.flipopactive)
                --Duel.RegisterEffect(e1, tp)

                local e2=e1:Clone()
                e2:SetCode(EVENT_CHAINING)
                --Duel.RegisterEffect(e2, tp)

                local token=Duel.CreateToken(tp, id+1)
                Duel.Remove(token, POS_FACEUP, REASON_RULE)
                Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
            end
            e:SetLabel(1)
end

function s.flipconactive(e,tp,eg,ep,ev,re,r,rp)
	return true
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
            local op=Duel.SelectEffect(tp, {true, aux.Stringid(id,0)},
            {true, aux.Stringid(id,1)})
            if op==1 then
                Duel.Hint(HINT_CARD,tp,id)
                Duel.TagSwap(tp)
            end
end