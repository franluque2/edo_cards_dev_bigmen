--Shackles of Johtunheim
--Duel.LoadScript("big_aux.lua")

local s, id = GetID()
function s.initial_effect(c)
    --Activate Skill
    aux.AddSkillProcedure(c, 2, false, nil, nil)
    local e1 = Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_STARTUP)
    e1:SetCountLimit(1)
    e1:SetRange(0x5f)
    e1:SetLabel(0)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
end

function s.op(e, tp, eg, ep, ev, re, r, rp)
    if e:GetLabel() == 0 then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE + PHASE_STANDBY)
        e1:SetCondition(s.flipcon)
        e1:SetOperation(s.flipop)
        Duel.RegisterEffect(e1, tp)

        --other passive duel effects go here

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_DISABLE)
        e7:SetTargetRange(LOCATION_ONFIELD,0)
        e7:SetCondition(s.discon)
        e7:SetTarget(aux.TargetBoolFunction(Card.IsCode,92107604))
        Duel.RegisterEffect(e7, tp)
    end
    e:SetLabel(1)
end

function s.lokifilter(c)
    return c:IsFaceup() and c:IsCode(67098114)
end

function s.discon(e)
	return not Duel.IsExistingMatchingCard(s.lokifilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end


Duel.Remove = (function()
    local oldfunc = Duel.Remove
    return function(g, pos, reason,...)
        local res
        if g and type(g)=="Group" then
        if (g:GetFirst():GetLocation()&LOCATION_DECK~=0) and (Duel.GetFlagEffect(1 - g:GetFirst():GetControler(), id) > 0) then
            local rescard = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_EFFECT)
            if rescard:GetHandler():IsSetCard(0x180) and not rescard:GetHandler():IsCode(29595202) then
                local g2=Group.CreateGroup()
                res = oldfunc(g2, pos, reason,...)
            else
                res = oldfunc(g, pos, reason,...)
            end
        else
            res = oldfunc(g, pos, reason,...)
        end
    else
        if (g:GetLocation()&LOCATION_DECK~=0) and (Duel.GetFlagEffect(1 - g:GetControler(), id) > 0) then
            local rescard = Duel.GetChainInfo(Duel.GetCurrentChain(), CHAININFO_TRIGGERING_EFFECT)
            if rescard:GetHandler():IsSetCard(0x180) and not rescard:GetHandler():IsCode(29595202) then
                local g2=Group.CreateGroup()
                res = oldfunc(g2, pos, reason,...)
            else
                res = oldfunc(g, pos, reason,...)
            end
        else
            res = oldfunc(g, pos, reason,...)
        end
    end
        return res
    end
end)()



function s.flipcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentChain() == 0 and Duel.GetTurnCount() == 1 and Duel.GetFlagEffect(tp, id) == 0
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    Duel.Hint(HINT_CARD, tp, id)


    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
end
