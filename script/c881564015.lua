--Sasaki The Fated Assailant
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be Special Summoned, except by the effect of a "Fated" card.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)

    --Once per turn, during the End Phase: Return this card to the hand.
    local sme,soe=Spirit.AddProcedure(c)
    c:RegisterFlagEffect(FLAG_SPIRIT_RETURN,0,0,1)

    -- Your opponent cannot target Spellcaster monsters you control for attacks.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atktg)
    e2:SetCondition(function(e) return e:GetHandler():IsFaceup() end)
    c:RegisterEffect(e2)

    
    --Gains ATK equal to its own DEF during your opponent's turn. 
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetCondition(function(e) return Duel.IsTurnPlayer(1-e:GetHandler():GetControler()) end)
    e3:SetValue(function(e,c) return c:GetDefense() end)
    c:RegisterEffect(e3)


    -- Unaffected by other monsters' effects, except those equipped with an equip spell or that have battled this monster.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(s.valfunc)
    c:RegisterEffect(e4)

    --aux to check if a monster battled this this turn
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_BATTLED)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetOperation(s.checkop)
    c:RegisterEffect(e5)

    -- If this card is destroyed by a card effect or banished : You can add 1 "Shiranui Style Swallow's Slash" from your Deck or GY to your hand, and if you do, Special Summon this card, but its effects are negated, also banish it when it leaves the field.

    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,0))
    e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_DESTROYED)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCountLimit(1,id)
    e6:SetCondition(s.spcon)
    e6:SetTarget(s.sptg)
    e6:SetOperation(s.spop)
    c:RegisterEffect(e6)

    local e7=e6:Clone()
    e7:SetCode(EVENT_REMOVE)
    e7:SetCondition(s.spcon2)
    c:RegisterEffect(e7)
end
s.listed_series={SET_FATED}
s.listed_names={04333086} --Shiranui Style Swallow Slash

function s.splimit(e,se,sp,st)
    return se:GetHandler():IsSetCard(SET_FATED)
end

function s.atktg(e,c)
    return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsControler(e:GetHandlerPlayer())
end

function s.valfunc(e,te)
    local tc=te:GetHandler()
    if te:GetOwner()==e:GetOwner() then return false end
    if not tc:IsType(TYPE_MONSTER) then return false end
    if tc:GetEquipCount()>0 then return false end
    local battled_this_turn=tc:GetFlagEffect(id)>0
    return not battled_this_turn
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if bc then
        bc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_EFFECT)
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return true
end

function s.thfilter(c)
    return c:IsCode(04333086) and c:IsAbleToHand()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
            if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
                --Negate its effects
                local e1=Effect.CreateEffect(c)
                e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                c:RegisterEffect(e1)
                local e2=Effect.CreateEffect(c)
                e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                c:RegisterEffect(e2)
                --Banish it when it leaves the field
                local e3=Effect.CreateEffect(c)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
                e3:SetDescription(3300)
                e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
                e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
                e3:SetValue(LOCATION_REMOVED)
                c:RegisterEffect(e3)
            end
        end
    end
end