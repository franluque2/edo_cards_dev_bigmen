--Alien Vanguard
local s,id=GetID()
function s.initial_effect(c)
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_REPTILE),1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)

end
s.counter_list={COUNTER_A}

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCounter(tp, LOCATION_ONFIELD, LOCATION_ONFIELD, COUNTER_A)>0
end

function s.thfilter(c)
	return c:PlacesCounter(COUNTER_A) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(Card.IsRace,1,nil,RACE_REPTILE)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    if Duel.SelectEffectYesNo(tp,c,96) then
        local num=#eg:Filter(Card.IsRace,nil,RACE_REPTILE)
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<num then
            num=Duel.GetLocationCount(tp,LOCATION_SZONE)
        end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local g=eg:FilterSelect(tp,Card.IsRace,1,num,nil,RACE_REPTILE)
        e:SetLabelObject(g)
        return true
    else return false end
end

function s.repval(e,c)
    return c:IsRace(RACE_REPTILE)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    if not g then return end
    for tc in aux.Next(g) do
        if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            --Treated as a Continuous Spell
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
            tc:RegisterEffect(e1)

            --Once per turn, during the End Phase: You can Special Summon this card. 
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetDescription(aux.Stringid(id,2))
            e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
            e2:SetCode(EVENT_PHASE+PHASE_END)
            e2:SetRange(LOCATION_SZONE)
            e2:SetCountLimit(1)
            e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
                return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            end)
            e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
                if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
                Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
            end)
            e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
                local c=e:GetHandler()
                if c:IsRelateToEffect(e) then
                    Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
                end
            end)
            e2:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
    end
end