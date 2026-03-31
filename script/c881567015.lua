--Protoss Carrier
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    --When this card is Special Summoned, if it is not the first turn, place 4 Guard counters on it.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(function(_,tp) return Duel.GetTurnCount()>1 end)
    e2:SetOperation(function(e,tp) for i = 1, 4, 1 do
        WbAux.PlaceProtossGuardCounter(e:GetHandler(),e)
            end  end)
    c:RegisterEffect(e2)

    --During your Main Phase, you can remove any number of Guard Counters from this card; Special Summon that many "Protoss Interceptor Token(s)" (Level 1 / LIGHT / Cyberse / 1000 ATK / 0 DEF), also you cannot Special Summon monsters for the rest of this turn, except Machine, Psychic and Cyberse monsters.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

end
s.listed_series={SET_PROTOSS}
s.listed_names={id+1}

function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsTurnPlayer(c:GetControler()) and Duel.GetTurnCount()%2==0
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetCounter(0x1021)>0 end
    local ct=e:GetHandler():GetCounter(0x1021)
    if ct>Duel.GetLocationCount(tp, LOCATION_MZONE) then ct=Duel.GetLocationCount(tp, LOCATION_MZONE) end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ct=1 end
    local t={}
    for i=1,ct do t[i]=i end
    local ac=Duel.AnnounceNumber(tp,table.unpack(t))
    e:SetLabel(ac)
    e:GetHandler():RemoveCounter(tp,0x1021,ac,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0xd09,TYPES_TOKEN,1000,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT,POS_FACEUP) end
    local num=e:GetLabel()
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,num,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,num,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    if ct>Duel.GetLocationCount(tp, LOCATION_MZONE) then return end
    if ct<=0 then return end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and ct~=1 then return end
    for i=1,ct do
        local token=Duel.CreateToken(tp,id+1)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
    end
    Duel.SpecialSummonComplete()
end