--Power of the Supreme Darkness
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


function s.fusionfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_EVIL_HERO) and (c:GetFlagEffect(id)==0) and not c:IsAttribute(ATTRIBUTE_DARK)
end

function s.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end

function s.oppmonster(c,fc,sumtype,tp)
    return c:GetControler()~=tp and not Duel.IsExistingMatchingCard(s.atkfilter, tp, 0, LOCATION_MZONE, 1, c, c:GetAttack())
end

function s.ctfusmat(c,fc,sumtype,tp)
    return c:IsSetCard(SET_EVIL_HERO,fc,sumtype,tp) and c:IsCanBeFusionMaterial(e,tp)
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()


    		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_SUPREME_CASTLE)
		e2:SetTargetRange(1,0)
		Duel.RegisterEffect(e2,tp)


                local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(function() return Duel.IsExistingMatchingCard(s.fusionfilter, tp, LOCATION_ALL, 0, 1, nil) end)
    e1:SetOperation(s.rewriteevilheroes)
    Duel.RegisterEffect(e1,tp)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(511002961)
    e3:SetTarget(function (_,_c) return _c:IsOriginalCode(58554959) end)
    e3:SetTargetRange(LOCATION_ALL,0)
    Duel.RegisterEffect(e3,tp)


end

function s.rewriteevilheroes(e,tp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.fusionfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)

        Fusion.AddProcMix(tc,true,true,s.oppmonster,s.ctfusmat)

    end
end
