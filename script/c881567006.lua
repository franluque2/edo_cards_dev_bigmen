--Protoss Dark Archon
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,id-2,{id-3,id-2})
	Fusion.AddContactProc(c,s.contactfil,s.contactop,aux.FALSE)

    --The first two times this card would be destroyed by battle or card effect this turn, it is not destroyed.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e1:SetCountLimit(2)
    e1:SetValue(s.valcon)
    c:RegisterEffect(e1)

    --Once per turn: you can pay half your LP, then target 1 face-up monster your opponent controls; take control of it, but it cannot attack this turn, also banish it if it would leave the field.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.ctlcost)
    e2:SetTarget(s.ctltg)
    e2:SetOperation(s.ctlop)
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
s.listed_names={id-3,id-2}

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

function s.ctlcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.PayLPCost(tp,Duel.GetLP(tp)/2)
end

function s.ctlfilter(c)
    return c:IsFaceup() and c:IsAbleToChangeControler()
end

function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(s.ctlfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.ctlfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1,true)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        e2:SetValue(LOCATION_REMOVED)
        tc:RegisterEffect(e2,true)
    end
end