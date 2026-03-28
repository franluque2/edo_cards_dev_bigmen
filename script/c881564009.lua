--Fated Noble Arms - Excalibur!
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    --Equip only to an "Artorigus" Monster. 
    	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_ARTORIGUS))

        --Once per turn, at the start of the Damage Step, if the equipped monster battles: You can send all other Equip Spells you control to the GY; the equipped monster gains 1500 ATK for each card sent until the end of the damage step.
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,0))
        e1:SetCategory(CATEGORY_ATKCHANGE)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
        e1:SetCode(EVENT_BATTLE_START)
        e1:SetRange(LOCATION_SZONE)
        e1:SetCondition(s.atkcon)
        e1:SetTarget(s.atktg)
        e1:SetCost(s.atkcost)
        e1:SetOperation(s.atkop)
        c:RegisterEffect(e1)
end
s.listed_series={SET_ARTORIGUS}

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and (Duel.GetAttackTarget()==ec or Duel.GetAttacker()==ec)
end

function s.sendfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end

function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_SZONE,0,1,e:GetHandler()) end
    local g=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_SZONE,0,e:GetHandler())
    Duel.SendtoGrave(g,REASON_COST)
    e:SetLabel(g:GetCount())
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler():GetEquipTarget(),1,0,0)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
    local ct=e:GetLabel()
    if ct>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(ct*1500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
        ec:RegisterEffect(e1)
    end
end