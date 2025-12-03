--Doomed Spirit Message - I
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetTarget(s.tgtg)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.adcost)
    e3:SetTarget(s.adtg)
    e3:SetOperation(s.adop)
    c:RegisterEffect(e3)

    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.ctfilter)
end
s.listed_series={SET_SPIRIT_MESSAGE}
s.listed_names={CARD_DESTINY_BOARD}

function s.tgtg(e,c)
    return (c:IsSetCard(SET_SPIRIT_MESSAGE) or c:IsCode(CARD_DESTINY_BOARD)) and c:IsFaceup()
end

function s.ctfilter(c)
    return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end

function s.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)>0 then return false end
        return true
    end
    -- Cannot Special Summon from the Extra Deck this turn, except Fusion Monsters
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION) end)
    Duel.RegisterEffect(e1,tp)
end

function s.adfilter(c)
    return (c:IsCode(CARD_DESTINY_BOARD) or (c:IsLevel(3) and c:IsRace(RACE_FIEND)) or (c:ListsCode(CARD_DESTINY_BOARD))) and c:IsAbleToHand()
end

function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_DECK,0,nil)
    if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,tp,1)
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
        if #sg==2 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)

            Duel.BreakEffect()
            Duel.ShuffleHand(tp)
            Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
        end
    end
end