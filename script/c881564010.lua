--Fated Noble Arms - Avalon
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    --Equip only to a "Fated" Monster. 
    	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_FATED))
        --you can only control 1
	c:SetUniqueOnField(1,0,id)

        --While you control "Fated Noble Knight - Saber", apply the following effects based on the type of the equipped monster:
        --- Spirit Monster: The equipped monster cannot be destroyed by battle or card effects, also your opponent cannot target it with card effects.
        --- Non-Spirit monster: Spirit monsters you control are unaffected by card effects that would make them leave the field.
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_EQUIP)
        e1:SetCondition(s.spiritcon)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        c:RegisterEffect(e2)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_EQUIP)
        e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e3:SetCondition(s.spiritcon)
        e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e3:SetValue(aux.tgoval)
        c:RegisterEffect(e3)

        --non-Spirit

            local es1=Effect.CreateEffect(c)
    es1:SetType(EFFECT_TYPE_SINGLE)
    es1:SetCode(EFFECT_IMMUNE_EFFECT)
    es1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    es1:SetRange(LOCATION_MZONE)
    es1:SetValue(s.imval)
    --send replace for comprehensive protection
    local es2=Effect.CreateEffect(c)
    es2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    es2:SetCode(EFFECT_SEND_REPLACE)
    es2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    es2:SetRange(LOCATION_MZONE)
    es2:SetTarget(s.reptg)
    es2:SetValue(function(e,c) return false end)

        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e4:SetRange(LOCATION_SZONE)
        e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e4:SetTargetRange(LOCATION_MZONE,0)
        e4:SetTarget(function(_,tc) return tc:IsType(TYPE_SPIRIT) end)
        e4:SetLabelObject(es1)
        e4:SetCondition(s.nonspiritcon)
        c:RegisterEffect(e4)
        local e5=e4:Clone()
        e5:SetLabelObject(es2)
        c:RegisterEffect(e5)

end
s.listed_series={SET_FATED}
s.listed_names={881564008} -- Fated Noble Knight - Saber

function s.spiritcon(e)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and ec:IsSetCard(SET_FATED) and ec:IsType(TYPE_SPIRIT) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,881564008),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

function s.leaveChk(c,category)
    local ex,tg=Duel.GetOperationInfo(0,category)
    return ex and tg~=nil and tg:IsContains(c)
end

function s.imval(e,te)
    if not te then return false end
    if e==te then return false end
    local c=e:GetHandler()
    return (c:GetDestination()>0 and c:GetReasonEffect()==te)
        or (s.leaveChk(c,CATEGORY_TOHAND) or s.leaveChk(c,CATEGORY_DESTROY) or s.leaveChk(c,CATEGORY_REMOVE)
        or s.leaveChk(c,CATEGORY_TODECK) or s.leaveChk(c,CATEGORY_RELEASE) or s.leaveChk(c,CATEGORY_TOGRAVE))
end


function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsReason(REASON_EFFECT) and r&REASON_EFFECT~=0 and re 
        and re:GetOwner():IsControler(1-tp) end
    return true
end

function s.nonspiritcon(e)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and ec:IsSetCard(SET_FATED) and not ec:IsType(TYPE_SPIRIT) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,881564008),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end