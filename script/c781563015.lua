--Shackles of a Poisonous Idol
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		nil, nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_REMOVE)
    e0:SetCondition(s.tagcon)
    e0:SetOperation(s.tagop)
    Duel.RegisterEffect(e0, tp)

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVED)
    e1:SetCondition(s.shufflebackcon)
    e1:SetOperation(s.shufflebackop)
    Duel.RegisterEffect(e1, tp)
end

function s.shufflebackcon(e, tp, eg, ep, ev, re, r, rp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and re:GetHandler():IsCode(21076084) and rp == tp
end

function s.toshufflebackfilter(c)
    return c:IsFaceup() and c:IsAbleToDeck() and c:GetFlagEffectLabel(id) == 1
end

function s.tagcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(Card.IsControler, 1, nil, 1-tp) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and re:GetHandler():IsCode(21076084) and rp == tp
end

function s.tagop(e, tp, eg, ep, ev, re, r, rp)
    local tg = eg:Filter(Card.IsControler, nil, 1-tp)
    for tc in tg:Iter() do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1, 1)
    end
end


function s.shufflebackop(e, tp, eg, ep, ev, re, r, rp)
    local g=Duel.GetMatchingGroup(s.toshufflebackfilter, tp, 0, LOCATION_REMOVED, nil)
    if #g>0 then
        Duel.Hint(HINT_CARD,tp,id)
        Duel.SendtoDeck(g, 1-tp, SEQ_DECKBOTTOM, REASON_EFFECT)
        Duel.ShuffleDeck(1-tp)
    end
end