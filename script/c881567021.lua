--Khala's Light
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)

end
s.listed_series={SET_PROTOSS}
s.counter_place_list={0x1021} -- Guard Counter

function s.adtarget(c)
    return c:IsSetCard(SET_PROTOSS) and c:IsMonster() and c:IsAbleToHand()
end

function s.placetarget(c)
    return c:IsSetCard(SET_PROTOSS) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_LINK) and not c:IsForbidden() and c:CheckUniqueOnField(c:GetControler())
end

function s.fuprotossfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_PROTOSS)
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    --Add 1 "Protoss" monster from your Deck to your Hand.
	local b1=not Duel.HasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(s.adtarget,tp,LOCATION_DECK,0,1,nil)
    --Discard 1 card, then place 1 "Protoss" Link Spell from your Deck face-up on your field.
	local b2=not Duel.HasFlagEffect(tp,id+1) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler(),REASON_EFFECT) and Duel.IsExistingMatchingCard(s.placetarget,tp,LOCATION_DECK,0,1,nil)
    --Send any number of other cards from your Hand to the GY, then place 1 Guard Counter on that many "Protoss" cards you control. 
    local b3=not Duel.HasFlagEffect(tp,id+2) and Duel.IsExistingMatchingCard(s.fuprotossfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler(),REASON_EFFECT)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
        e:SetCategory(CATEGORY_HANDES)
        Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
        Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	elseif op==3 then
        e:SetCategory(CATEGORY_TOGRAVE)
        Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
        local ct=Duel.GetMatchingGroupCount(s.fuprotossfilter,tp,LOCATION_ONFIELD,0,nil)
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
        Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x1021)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)

    local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,0))
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    local op=e:GetLabel()
    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.adtarget,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    elseif op==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
        local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,e:GetHandler(),REASON_EFFECT)
        if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
            local sg=Duel.SelectMatchingCard(tp,s.placetarget,tp,LOCATION_DECK,0,1,1,nil)
            local tc=sg:GetFirst()
            if tc then
                Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
            end
        end
    elseif op==3 then
        local ct=Duel.GetMatchingGroupCount(s.fuprotossfilter,tp,LOCATION_ONFIELD,0,nil)
        if ct<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,ct,e:GetHandler(),REASON_EFFECT)
        local gc=g:GetCount()
        if gc>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
            local g2=ct:Select(tp, #g, #g)
            for tc in g2:Iter() do
                WbAux.PlaceProtossGuardCounter(tc,e)
            end
        end
    end
end

function s.splimit(e,c)
    return not c:IsRace(RACE_MACHINE) and not c:IsRace(RACE_PSYCHIC) and not c:IsRace(RACE_CYBERSE)
end
