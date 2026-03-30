--Protoss Pylon
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	
    --You cannot Normal or Special Summon monsters to your Zones this card points to, except "Protoss" monsters. This effect cannot be negated.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FORCE_MZONE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetTargetRange(0xff,0)
    e2:SetTarget(s.ztarget)
	e2:SetValue(s.znval)
	c:RegisterEffect(e2)

    --Once per Turn: You can add 1 "Protoss" card from your Deck or GY to your Hand, except "Protoss Pylon", also you cannot Special Summon monsters for the rest of this turn, except Machine, Psychic and Cyberse monsters.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    --At the Start of the Battle Phase: You can place 1 Guard Counter on each card this card points to (use WbAux.PlaceProtossGuardCounter)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetTarget(s.placetg)
    e4:SetOperation(s.placeop)
    c:RegisterEffect(e4)

end
s.listed_series={SET_PROTOSS}
s.counter_place_list={0x1021} -- Guard Counter

function s.ztarget(e,c)
    return c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_MONSTER) and not c:IsSetCard(SET_PROTOSS)
end

function s.znval(e,c,fp,rp,r)
    return ~(e:GetHandler():GetLinkedZone())
end

function s.thfilter(c)
    return c:IsSetCard(SET_PROTOSS) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,g)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.splimit(e,c)
    return not c:IsRace(RACE_MACHINE) and not c:IsRace(RACE_PSYCHIC) and not c:IsRace(RACE_CYBERSE)
end

function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetLinkedGroup():IsExists(Card.IsFaceup,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end

function s.placeop(e,tp,eg,ep,ev,re,r,rp)
    local lg=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
    if #lg>0 then
        for tc in lg:Iter() do
            WbAux.PlaceProtossGuardCounter(tc,e)
        end
    end
end