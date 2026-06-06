--Roots of the Mother Tree
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

local sunvineextracounts={}
sunvineextracounts[0]={}
sunvineextracounts[1]={}


function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.registersunvines(tp)

    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_MOVE)
    e2:SetCondition(function(_,_,eg) return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA) end)
    e2:SetOperation(s.completesunvines)
    Duel.RegisterEffect(e2,tp)

    s.completesunvines(nil, tp, nil, nil, nil, nil, nil, nil)

    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
    e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e6:SetTargetRange(LOCATION_MZONE,0)
    e6:SetTarget(s.efilter)
    e6:SetValue(1)
    Duel.RegisterEffect(e6, tp)
end


function s.efilter(e,c)
	return c:IsCode(91557476)
end


function s.registersunvines(tp)

    local g2=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_EXTRA,0,nil,SET_SUNVINE)
    for tc in g2:Iter() do
        local code=tc:GetCode()
        if not sunvineextracounts[tp][code] then
            sunvineextracounts[tp][code]=0
        end
        sunvineextracounts[tp][code]=sunvineextracounts[tp][code]+1
    end
end

function s.completesunvines(e,tp,eg,ep,ev,re,r,rp)

    for code, count in pairs(sunvineextracounts[tp]) do
        local num=Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, code)
        if count>num then
            for i=1, count-num do
                local token=Duel.CreateToken(tp, code)
                Duel.SendtoDeck(token, nil, SEQ_DECKBOTTOM, REASON_RULE)
            end
        end
    end
end