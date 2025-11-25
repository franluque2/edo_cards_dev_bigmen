--Illuminated Insect Queen
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),3)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCondition(s.imcon)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.imtg)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_MAIN_END)
    e3:SetCountLimit(1,{id,0})
    e3:SetCondition(function() return Duel.IsMainPhase() end)
    e3:SetCost(s.drawcost)
    e3:SetTarget(s.drawtg)
    e3:SetOperation(s.drawop)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCountLimit(1,{id,1})
    e4:SetTarget(s.tkntg)
    e4:SetOperation(s.tknop)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_PHASE+PHASE_END)
    e5:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e5)
end
s.listed_names={id+1}

function s.imcon(e)
    return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_NORMAL)
end
function s.imtg(e,c)
    return not c:IsType(TYPE_NORMAL)
end

function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_INSECT) end
    local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,e:GetHandler(),RACE_INSECT)
    Duel.Release(g,REASON_COST)
end

function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end

function s.tkntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
        and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN_MONSTER,200,200,2,RACE_INSECT,ATTRIBUTE_LIGHT)
            and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
         end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end

function s.tknop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1
        or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN_MONSTER,200,200,2,RACE_INSECT,ATTRIBUTE_LIGHT) or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
    for _=1,2 do
        local tkn=Duel.CreateToken(tp,id+1)
        Duel.SpecialSummonStep(tkn, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
    end
    Duel.SpecialSummonComplete()
end