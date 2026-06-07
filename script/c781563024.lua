--Haunting of the Yokai
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)


    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end


function s.backrowfilter(c)
    return c:IsCode(98596596) and c:GetFlagEffect(id)==0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.placemezukis(e,tp,eg,ep,ev,re,r,rp)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(function() return Duel.IsExistingMatchingCard(s.backrowfilter, tp, LOCATION_ALL, 0, 1, nil) end)
    e1:SetOperation(s.rewritebackrow)
    Duel.RegisterEffect(e1,tp)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetCountLimit(1)
    e2:SetCondition(function() return Duel.GetTurnPlayer()==tp end)
    e2:SetOperation(s.retop)
    Duel.RegisterEffect(e2,tp)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.bancon)
    e3:SetOperation(s.banop)
    Duel.RegisterEffect(e3,tp)
end

function s.placemezukis(e,tp,eg,ep,ev,re,r,rp)
    for i=1,3 do
        local token=Duel.CreateToken(tp,92826944)
        Duel.SendtoGrave(token, REASON_RULE)
    end
end

function s.rewritebackrow(e,tp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.backrowfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)

        local effs={tc:GetOwnEffects()}
        for _,eff in ipairs(effs) do
            if not eff:IsHasType(EFFECT_TYPE_ACTIVATE) then
                local neweff=eff:Clone()
                neweff:SetRange(LOCATION_GRAVE)
                tc:RegisterEffect(neweff)
            end
        end
    end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, LOCATION_REMOVED, 0, nil)
    if #g>0 then
        Duel.SendtoGrave(g, REASON_RETURN+REASON_RULE)
    end
end

function s.tartarusfilter(c,tp)
    return c:IsCode(43363035) and c:GetControler()==tp and c:IsPreviousLocation(LOCATION_DECK)
end

function s.bancon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.tartarusfilter,1,nil,tp)
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.tartarusfilter,nil,tp)
    Duel.Remove(g,POS_FACEUP,REASON_RULE)
end