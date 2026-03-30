--Protoss High Archon
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,id-2,{id-1,id-2})
	Fusion.AddContactProc(c,s.contactfil,s.contactop,aux.FALSE)

    --The first two times this card would be destroyed by battle or card effect this turn, it is not destroyed.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e1:SetCountLimit(2)
    e1:SetValue(s.valcon)
    c:RegisterEffect(e1)

    --Can attack all monsters your opponent controls, once each.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ATTACK_ALL)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    --Once per turn, during the End Phase: Banish this card.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.rmtarg)
    e3:SetOperation(function(_e,tp) Duel.Remove(_e:GetHandler(),POS_FACEUP,REASON_EFFECT) end)
    c:RegisterEffect(e3)
end
s.listed_series={SET_PROTOSS}
s.listed_names={id-1,id-2}

function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end

function s.valcon(e,re,r,rp)
    return (r&REASON_BATTLE)~=0 or (r&REASON_EFFECT)~=0
end

function s.rmtarg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end