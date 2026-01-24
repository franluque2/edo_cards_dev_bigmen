--Shinji the Fated Master
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --If a Field Spell is on the Field: You can Special Summon this card (from your Hand), then you can add 1 "The Fated Reptillianne Rider" from your Deck to your hand, also you cannot Special Summon monsters for the rest of this turn, except DARK monsters.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- You can Normal Summon 1 DARK Spirit Monster each turn in addition to your Normal Summon/Set (You can only gain this effect once per turn).
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
    e2:SetTarget(function(_,c) return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SPIRIT) end)
    c:RegisterEffect(e2)

    --. If this card on the field is destroyed and sent to the GY: Add 1 "Dregs of Angra Mainju" from Outside the Duel to both players' hand, then destroy 1 Spirit monster on your Hand or Field.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,4))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_CONJURE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

end
s.listed_names={CARD_DREGS_ANGRA_MAINYU, 881564061} --The Fated Reptillianne Rider
s.listed_series={SET_FATED}


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil,TYPE_FIELD)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.adfilter(c)
    return c:IsCode(881564061) and c:IsAbleToHand()
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        if Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.adfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
        --You cannot Special Summon monsters for the rest of this turn, except DARK monsters.
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetTarget(function(_,c) return not c:IsAttribute(ATTRIBUTE_DARK) end)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end

function s.destructablespiritfilter(c)
    return c:IsType(TYPE_SPIRIT) and c:IsDestructable() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    WbAux.AddDregs(tp,1)
    WbAux.AddDregs(1-tp,1)
    local g=Duel.GetMatchingGroup(s.destructablespiritfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local tc=g:Select(tp, 1,1,nil)
        if #tc>0 then
            Duel.Destroy(tc,REASON_EFFECT)
        end
    end
end