--Twin-Headed Card Dragon
local s, id = GetID()
function s.initial_effect(c)

    --Activate Skill
    local e1 = Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCountLimit(1)
    e1:SetLabel(0)
    e1:SetRange(LOCATION_ALL)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)

end

local ID_END_OF_PHASE = id - 500 + 1
local ID_END_OF_TURN = id - 500 + 2
local ID_TURN_BACK_ON = id - 500 + 3


function s.op(e, tp, eg, ep, ev, re, r, rp)
    if e:GetLabel() == 0 then

        Duel.Hint(HINT_CARD, tp, id)

        Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

        Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)

        if e:GetHandler():GetPreviousLocation() == LOCATION_HAND then
            Duel.Draw(tp, 1, REASON_EFFECT)
        end

        if Duel.GetFlagEffect(tp, id)==1 then
            Duel.Hint(HINT_SKILL_COVER,tp,id|(300000000<<32))
            Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))

            
            local e3 = Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
            e3:SetCode(EVENT_CHAIN_SOLVED)
            e3:SetOperation(s.acop)
            Duel.RegisterEffect(e3, tp)

            local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_FREE_CHAIN)
			e1:SetCondition(s.flipcon2)
			e1:SetOperation(s.flipop2)
			Duel.RegisterEffect(e1,tp)

        end
    end
    e:SetLabel(1)
end



function s.acop(e, tp, eg, ep, ev, re, r, rp)
    

        local r1 = Duel.GetFlagEffect(tp, ID_END_OF_PHASE) == 0 and
            Duel.GetFlagEffect(tp, ID_END_OF_TURN) == 0 and
            Duel.GetFlagEffect(tp, ID_TURN_BACK_ON) == 0

        if r1 then

            local op=Duel.SelectEffect(tp, {true, aux.Stringid(id,0)},
            {true, aux.Stringid(id,1)},
            {true, aux.Stringid(id,2)},
            {true, aux.Stringid(id,3)},
            {true, aux.Stringid(id,4)})

            if op==1 then
                Duel.Hint(HINT_CARD,tp,id)
                Duel.TagSwap(tp)
            elseif op==2 then
                Duel.RegisterFlagEffect(tp, ID_END_OF_PHASE, RESET_EVENT+RESET_PHASE+Duel.GetCurrentPhase(), 0, 0)
            elseif op==3 then
                Duel.RegisterFlagEffect(tp, ID_END_OF_TURN, RESET_EVENT+RESET_PHASE+PHASE_END, 0, 0)
            elseif op==4 then
                Duel.RegisterFlagEffect(tp, ID_TURN_BACK_ON, 0, 0, 0)
            end
        end
    
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	return aux.CanActivateSkill(tp)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)

    local b1=Duel.GetFlagEffect(tp, ID_TURN_BACK_ON)>0

    local op=Duel.SelectEffect(tp, {true, aux.Stringid(id,0)},
    {b1, aux.Stringid(id,5)},
    {true, aux.Stringid(id,4)})
    if op==1 then
        Duel.Hint(HINT_CARD,tp,id)
        Duel.TagSwap(tp)

    elseif op==2 then
        Duel.ResetFlagEffect(tp, ID_TURN_BACK_ON)
    end
end

