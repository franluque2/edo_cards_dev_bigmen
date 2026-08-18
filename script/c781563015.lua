--An Angelic Poisonous Idol
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

                local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_STARTUP)
    e3:SetRange(0x5f)
    e3:SetCountLimit(1)
    e3:SetOperation(s.shuffledownop)
    c:RegisterEffect(e3)

	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		nil, nil, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end


function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)


    local g1 = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, nil, 35371948)
	if #g1 > 0 then
		Duel.MoveToDeckTop(g1:GetFirst())
	end
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

        local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e2:SetTarget(s.lowleveltrickstarfilter)
    Duel.RegisterEffect(e2, tp)

        local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_CHANGE_DAMAGE)
    e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e7:SetTargetRange(0,1)
    e7:SetCondition(function(_e) return Duel.IsTurnPlayer(_e:GetHandlerPlayer()) and Duel.GetTurnCount()==1 end)
    e7:SetValue(s.damval)
    Duel.RegisterEffect(e7, tp)

end

function s.damval(e,re,val,r,rp,rc)
    if r&REASON_EFFECT~=0 then
        return 1
    else
        return val
    end
end

function s.lowleveltrickstarfilter(e,c)
    return c:IsLevelBelow(3) and c:IsSetCard(SET_TRICKSTAR)
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