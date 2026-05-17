--Triple Attack! Thunder Water and Wind!
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		nil, nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

        local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_STARTUP)
    e3:SetRange(0x5f)
    e3:SetCountLimit(1)
    e3:SetOperation(s.shuffledownop)
    c:RegisterEffect(e3)
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

            local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_DISABLE)
        e7:SetTargetRange(LOCATION_ONFIELD,0)
        e7:SetCondition(function () return Duel.IsBattlePhase() end)
        e7:SetTarget(aux.TargetBoolFunction(Card.IsCode,34771947))
        Duel.RegisterEffect(e7, tp)

end


local bricks={25833572,25955164,98434877,62340868}

function s.cardfilter(c, tp)
    return c:IsCode(table.unpack(bricks)) and c:GetSequence() >= (Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) - (20))
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
    if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
    if #g > 0 then
        Duel.MoveToDeckBottom(g)
    end
end
