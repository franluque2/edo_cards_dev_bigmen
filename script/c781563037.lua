--Dino DNA Splicing
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

        local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_STARTUP)
    e3:SetRange(0x5f)
    e3:SetCountLimit(1)
    e3:SetOperation(s.toextraop)
    c:RegisterEffect(e3)

        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local togravemons={511001647,47349310,81782101}
local CARD_LOST_WORLD=17228908
function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end
function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.fillgraveyard(e,tp,eg,ep,ev,re,r,rp)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAIN_SOLVING)
    e1:SetCondition(s.negmisccon)
    e1:SetOperation(s.negmiscop)
    Duel.RegisterEffect(e1,tp)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_ADD_SETCODE)
    e2:SetValue(SET_EVOLUTION_PILL)
    e2:SetTargetRange(LOCATION_ALL,0)
    e2:SetTarget(s.evolutionpilltarget)
    Duel.RegisterEffect(e2,tp)

    --rewrite lost world
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetCondition(s.lostworldrewritecon)
    e3:SetOperation(s.lostworldrewriteop)
    Duel.RegisterEffect(e3,tp)
end

function s.evolutionpilltarget(e,c)
    return c:IsOriginalCode(CARD_LOST_WORLD)
end

function s.negmisccon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if rp~=tp then return false end
    return re:IsActiveType(TYPE_MONSTER) and rc:IsCode(38572779) and rc:IsPreviousLocation(LOCATION_HAND) and Duel.IsChainNegatable(ev)
end

function s.negmiscop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end

function s.fillgraveyard(e,tp,eg,ep,ev,re,r,rp)
    for _,code in ipairs(togravemons) do
        local token=Duel.CreateToken(tp, code)
        Duel.SendtoGrave(token, REASON_RULE)
    end
end

function s.toextraop(e, tp, eg, ep, ev, re, r, rp)
    local g1 = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 18940556)
	if #g1 > 0 then
        for tc in g1:Iter() do
            local token=Duel.CreateToken(tp,id+1)
            Duel.SendtoDeck(token, tp, SEQ_DECKSHUFFLE, REASON_RULE)
        end
        Duel.RemoveCards(g1)
	end
end

function s.lostworldfilter(c)
    return c:IsCode(CARD_LOST_WORLD) and c:GetFlagEffect(id)==0
end

function s.lostworldrewritecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.lostworldfilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.lostworldrewriteop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.lostworldfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 0)

        local effs={tc:GetOwnEffects()}
        for _,eff in ipairs(effs) do
            if eff:GetCode()==EFFECT_CANNOT_BE_EFFECT_TARGET then
                eff:Reset()
            end
        end
    end
end