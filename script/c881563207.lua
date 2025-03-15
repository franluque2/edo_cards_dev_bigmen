--Ten Stonehearts - Jade of Credit
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(s.mfilter),3,99)


    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(s.val)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(function(_,_,_,ep) Duel.RegisterFlagEffect(ep,id,RESET_PHASE|PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
	end)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetTarget(s.disable)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
    
end
s.listed_names={881563205}

function s.mfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_IPC,lc,sumtype,tp) or c:IsType(TYPE_TOKEN,lc,sumtype,tp)
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return  Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,881563205,nil,TYPE_MONSTER+TYPE_TOKEN,1500,0,4,RACE_AQUA,ATTRIBUTE_DARK,POS_FACEUP,tp,0) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local token=Duel.CreateToken(tp,881563205)
    if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP) then
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_ATTACK_ALL)
        e3:SetValue(1)
        token:RegisterEffect(e3)

        aux.DelayedOperation(token,PHASE_BATTLE,id,e,tp,function(ag) Duel.Destroy(ag,REASON_RULE) end,nil,0)

    end
end

function s.disable(e,c)
    return c:IsType(TYPE_MONSTER) and c:GetAttack()==0 and c:IsFaceup()
end

function s.val(e,c)
    return -500*(Duel.GetFlagEffect(c:GetControler(),id)+Duel.GetFlagEffect(1-c:GetControler(),id))
end

