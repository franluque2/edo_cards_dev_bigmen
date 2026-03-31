--Protoss Blink
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --If you were not the Starting Player, you can activate this trap the turn it was Set.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetValue(function(e,c) e:SetLabel(1) end)
	e2:SetCondition(function(e) return s[e:GetHandlerPlayer()]~=0 end)
	c:RegisterEffect(e2)

    --If you control a "Protoss" monster: Banish any number of Machine, Psychic and Cyberse monsters you control.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCondition(s.bancon)
    e1:SetTarget(s.bantg)
    e1:SetOperation(s.banop)
    c:RegisterEffect(e1)


    --You can banish this card from your GY; Special Summon as many of the monsters that were banished by this card's effect as possible.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCost(Cost.SelfBanish)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)


    	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_STARTUP)
        ge1:SetCountLimit(1)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)

        s[0]=0
        s[1]=0
	end)

end
s.listed_series={SET_PROTOSS}

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    s[1-Duel.GetTurnPlayer()]=1
end

function s.fuprotossfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_PROTOSS)
end

function s.bancon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.fuprotossfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.banfilter(c)
    return c:IsFaceup() and (c:IsRace(RACE_MACHINE) or c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_CYBERSE)) and c:IsAbleToRemove()
end

function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_MZONE,0,1,nil) end
    local g=Duel.GetMatchingGroup(s.banfilter,tp,LOCATION_MZONE,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.banfilter,tp,LOCATION_MZONE,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local rg=g:Select(tp,1,#g,nil)
        Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
        for tc in rg:Iter() do
            tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,e:GetHandler():GetCardID())
        end

    end
end

function s.spfilter(c,e,tp)
    return c:IsFaceup() and c:IsSetCard(SET_PROTOSS) and c:GetFlagEffect(id)~=0 and c:GetFlagEffectLabel(id)==e:GetHandler():GetCardID() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
    local num=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if num>#g then num=#g end
    if num<=0 then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then num=1 end
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,num,num,nil)
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end