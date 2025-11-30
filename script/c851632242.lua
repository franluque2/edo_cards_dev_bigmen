--Chaos Wurm
local s,id=GetID()
function s.initial_effect(c)
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCost(s.tokencost)
    e1:SetTarget(s.tokentg)
    e1:SetOperation(s.tokenop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.millcon)
    e2:SetTarget(s.milltg)
    e2:SetOperation(s.millop)
    c:RegisterEffect(e2)



    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.ctfilter)
end
s.listed_names={30327675} -- Dark Beast Token
s.listed_series={SET_CHAOS}

function s.ctfilter(c)
    return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO))
end

function s.costfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end

function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)>0 then return false end
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    -- Cannot Special Summon from the Extra Deck this turn, except LIGHT or DARK Synchro Monsters
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,3))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)) end)
    Duel.RegisterEffect(e1,tp)
end

function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,30327675,0,TYPES_TOKEN,1000,500,2,RACE_FIEND,ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end

function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if Duel.IsPlayerCanSpecialSummonMonster(tp,30327675,0,TYPES_TOKEN,1000,500,2,RACE_FIEND,ATTRIBUTE_DARK) then
        local token=Duel.CreateToken(tp,30327675)
        Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.millcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_SYNCHRO+REASON_MATERIAL) and r==REASON_SYNCHRO+REASON_MATERIAL and c:GetReasonCard():IsSetCard(SET_CHAOS)
end

function s.milltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,5)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,5)
end

function s.millop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
    Duel.ConfirmDecktop(tp,5)
    local g=Duel.GetDecktopGroup(tp,5)
    if #g==0 then return end
    local tg=g:Filter(Card.IsAttribute,nil,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
    if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=tg:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
        g:Sub(sg)
    end
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
    end
end