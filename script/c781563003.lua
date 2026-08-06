--Shackles of an Undercover Hunter
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
    s.rewritecards(e, tp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

    local c = e:GetHandler()

    s.addactioncards(e,tp)

    s.placetoyvendor(e,tp)
    --local e1 = Effect.CreateEffect(c)
    --e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    --e1:SetCode(EVENT_PREDRAW)
    --e1:SetCountLimit(1)
    --e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(tp) end)
    --e1:SetOperation(s.addactioncards)
    --Duel.RegisterEffect(e1, tp)


    local e6 = Effect.GlobalEffect()
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_IGNORE_RANGE +
    EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SET_AVAILABLE)
    e6:SetCode(EFFECT_BECOME_QUICK)
    e6:SetTargetRange(0, 0xff)
    e6:SetTarget(aux.TargetBoolFunction(Card.IsType, TYPE_ACTION))
    Duel.RegisterEffect(e6, tp)
    local e7 = e6:Clone()
    e7:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    Duel.RegisterEffect(e7, tp)
    local e8 = e6:Clone()
    e8:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
    Duel.RegisterEffect(e8, tp)

    local e9 = Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e9:SetCode(EVENT_TURN_END)
    e9:SetCountLimit(1)
    e9:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(tp) end)
    e9:SetOperation(s.removeactioncards)
    Duel.RegisterEffect(e9, tp)

    local e10=Effect.CreateEffect(e:GetHandler())
    e10:SetType(EFFECT_TYPE_FIELD)
    e10:SetCode(EFFECT_CANNOT_TRIGGER)
    e10:SetTargetRange(LOCATION_MZONE,0)
    e10:SetCondition(s.discon)
    e10:SetTarget(s.actfilter)
    Duel.RegisterEffect(e10, tp)

end

function s.discon(e)
	return (Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()) and (Duel.GetTurnCount()==1)
end

function s.actfilter(e,c)
	return c:IsCode(78778375)
end

function s.rewritecards(e, tp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ALL, 0, nil, 80889750)

    if #g > 0 then
        for tc in g:Iter() do
            if tc:GetFlagEffect(id) == 0 then
                local eff = { tc:GetCardEffect() }
                for _, teh in ipairs(eff) do
                    if teh:GetCode() & EFFECT_FUSION_MATERIAL == EFFECT_FUSION_MATERIAL then
                        teh:Reset()
                    end
                end
                tc:RegisterFlagEffect(id, 0, 0, 0)

                Fusion.AddProcMixRep(tc, true, true, s.mfilter2, 1, 1, s.mfilter1)
            end
        end
    end
end

function s.mfilter1(c, fc, sumtype, tp)
    return c:IsSetCard(SET_FRIGHTFUR, fc, sumtype, tp) and c:IsType(TYPE_FUSION, fc, sumtype, tp)
end

function s.mfilter2(c, fc, sumtype, tp)
    return c:IsSetCard(SET_FLUFFAL, fc, sumtype, tp) or c:IsSetCard(SET_EDGE_IMP, fc, sumtype, tp)
end

local actioncards = { 150000020, 150000024, 150000042 }

function s.addactioncards(e, tp, eg, ep, ev, re, r, rp)
    --Duel.Hint(HINT_CARD, tp, id)

    local g = Group.CreateGroup()
    for i = 1, 3, 1 do
        local ac = actioncards[math.random(#actioncards)]
        local tc = Duel.CreateToken(1 - tp, ac)
        tc:RegisterFlagEffect(id, 0, 0, 0, tp)
        g:AddCard(tc)
    end
    Duel.SendtoHand(g, nil, REASON_RULE)
    Duel.ConfirmCards(tp, g)
end

function s.remfilter(c)
    return c:IsType(TYPE_ACTION) and c:IsSpell() and c:GetFlagEffect(id) > 0
end

function s.removeactioncards(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.remfilter, tp, 0, LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_DECK, nil)
    Duel.RemoveCards(g)
end


function s.placetoyvendor(e,tp)
    local toyvendor = Duel.CreateToken(tp, 70245411)
    Duel.MoveToField(toyvendor,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    toyvendor:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id, 0))

    --before resolving the on field effect of "Toy Vendor" look if there's a fluffal card in deck we can move to the top
    local e1=Effect.CreateEffect(toyvendor)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetRange(LOCATION_SZONE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetCondition(s.movetodecktopcon)
    e1:SetOperation(s.movetodecktopop)
    toyvendor:RegisterEffect(e1)

end

function s.tomovecardfilter(c)
    return c:IsSetCard(SET_FLUFFAL) and c:IsMonster()
end

function s.movetodecktopcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc and rc==e:GetHandler()
end

function s.movetodecktopop(e,tp,eg,ep,ev,re,r,rp)
    local g1 = Duel.GetMatchingGroup(s.tomovecardfilter, tp, LOCATION_DECK, 0, nil)
	if #g1 > 0 then
		Duel.MoveToDeckTop(g1:GetFirst())
	end
end