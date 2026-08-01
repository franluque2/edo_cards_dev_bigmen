--Dark Deal of Catastrophe
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
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

    s.placecards(c,e,tp)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetCondition(s.hookinstantkillcon)
    e1:SetOperation(s.hookinstantkillop)
    Duel.RegisterEffect(e1, tp)
end
local HIDDEN_KNIGHT_HOOK=511000008
local HIDDEN_KNIGHTS={HIDDEN_KNIGHT_HOOK,511000957}
function s.placecards(c,e,tp)
    for _, code in ipairs(HIDDEN_KNIGHTS) do
        local token=Duel.CreateToken(tp, code)
        Duel.SendtoHand(token, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, token)

        local e1=Effect.CreateEffect(c)
        e1:SetCode(EFFECT_ADD_SETCODE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
        e1:SetValue(SET_BURNING_ABYSS)
        token:RegisterEffect(e1)

        token:RegisterFlagEffect(0,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id, 0))

    end
end

function s.hookinstantkillcon(e,tp,eg,ep,ev,re,r,rp)
    if not ((r&REASON_EFFECT)>0) then return false end
    if not re and re:GetHandler():IsCode(HIDDEN_KNIGHT_HOOK) then return false end
    if not re:GetHandler():IsControler(tp) then return false end
    return true
end

function s.hookinstantkillop(e,tp,eg,ep,ev,re,r,rp)
    local tc=re:GetHandler()
    if not tc then return end
    if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
        	local e4=Effect.CreateEffect(e:GetHandler())
            e4:SetDescription(aux.Stringid(id, 1))
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
            e4:SetReset(RESET_EVENT+RESETS_STANDARD)
            e4:SetCode(EFFECT_MATCH_KILL)
            tc:RegisterEffect(e4)
    end
end