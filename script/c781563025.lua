--Becoming the Mask
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

function s.terrafirmafilter(c)
    return c:IsCode(74711057) and c:GetFlagEffect(id)==0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()


        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(function() return Duel.IsExistingMatchingCard(s.terrafirmafilter, tp, LOCATION_ALL, 0, 1, nil) end)
    e1:SetOperation(s.rewriteterrafirma)
    Duel.RegisterEffect(e1,tp)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.setcon)
    e2:SetOperation(s.setop)
    Duel.RegisterEffect(e2,tp)
end

function s.rewriteterrafirma(e,tp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.terrafirmafilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)

	    Fusion.AddProcMixN(tc,true,true,s.matfilter,2)

    end
end

function s.matfilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(SET_HERO,fc,sumtype,tp) and c:GetAttribute(fc,sumtype,tp)~=0 and (not sg or not sg:IsExists(s.diffattrfilter,1,c,c:GetAttribute(fc,sumtype,tp),fc,sumtype,tp))
end
function s.diffattrfilter(c,attr,fc,sumtype,tp)
	return c:IsAttribute(attr,fc,sumtype,tp) and not c:IsHasEffect(511002961)
end

function s.spterrafirmafilter(c,tp)
    return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsCode(74711057)
end

function s.setfilter(c)
    return c:IsSSetable() and (c:IsCode(21143940) or (c:IsSetCard(SET_FUSION)))
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spterrafirmafilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_GRAVE, 0, 1, nil)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local setnum=Duel.GetLocationCount(tp, LOCATION_SZONE)
    if setnum<=0 then return end
    if not (Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_GRAVE, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 0))) then return end
    Duel.Hint(HINT_CARD, tp, id)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_GRAVE, 0, 1, setnum, nil)
    if #g>0 then
        Duel.SSet(tp,g)
    end
end