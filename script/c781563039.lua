--Princess of Frogs
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local TADPOLE=10456559
local TOADALLY_AWESOME=90809975
local DESFROG=84451804

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end
function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1, tp)

    --each time a frog card(s) is sent to your GY, place 1 TADPOLE in your GY from Outside the Duel
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.tadpolecon)
    e2:SetOperation(s.tadpoleop)
    Duel.RegisterEffect(e2, tp)
end

function s.toadfilter(c)
    return c:IsCode(TOADALLY_AWESOME) and c:GetFlagEffect(id)==0
end

function s.dtsfrogfilter(c)
    return c:IsCode(09910360) and c:GetFlagEffect(id)==0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return (Duel.GetMatchingGroupCount(s.toadfilter,tp,LOCATION_EXTRA,0,nil)>0) or (Duel.GetMatchingGroupCount(s.dtsfrogfilter,tp,LOCATION_EXTRA,0,nil)>0)
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.toadfilter,tp,LOCATION_EXTRA,0,nil)
    for tc in g1:Iter() do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RANK)
        e1:SetValue(5)
        tc:RegisterEffect(e1)

        local effs={tc:GetOwnEffects()}

        for _,eff in ipairs(effs) do
            if eff:GetCode()==EFFECT_SPSUMMON_PROC then
                eff:Reset()
            end
        end

	    Xyz.AddProcedure(tc,s.xyzfilter,nil,2,nil,nil,nil,nil,false)

        tc:RegisterFlagEffect(id,0,0,1)
    end

    local g2=Duel.GetMatchingGroup(s.dtsfrogfilter,tp,LOCATION_EXTRA,0,nil)
    for tc in g2:Iter() do
	    Fusion.AddContactProc(tc,s.contactfil,s.contactop,nil,nil,nil,nil,false)

        tc:RegisterFlagEffect(id,0,0,1)
    end
end

function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
end

function s.xyzfilter(c,xyz,sumtype,tp)
	return c:HasLevel() and c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_WATER,xyz,sumtype,tp)
end

function s.tadpolecon(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsSetCard,nil,SET_FROG)
    return #g>0 and g:IsExists(Card.IsControler, 1, nil, tp)
end

function s.tadpoleop(e,tp,eg,ep,ev,re,r,rp)
    local token=Duel.CreateToken(tp, TADPOLE)
    Duel.SendtoGrave(token, REASON_RULE)
end