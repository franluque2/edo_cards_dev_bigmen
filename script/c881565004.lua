--Mistral of the Winds of Destruction

Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
--You can reveal this card from your Hand; Add 1 "Revengeance of the Desperados" from your Deck to your hand, then discard a card, also you cannot Special Summon "Jetstream Sam of the Winds of Destruction" for the rest of this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,1})
    e1:SetCost(s.thcost)
    e1:SetCondition(function (e) return not s.qphandcon(e) end)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

       --During the Main Phase: You can Special Summon this card from your Hand, then if you control no other monsters, you can, immediately after this effect resolves, Fusion Summon 1 monster from your Extra Deck, using only this monster and 1 monster in your hand as material (if your opponent activated 15 or more cards or effects this turn, you can treat this card as a proper material).
        local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(function (e) return not s.qphandcon(e) end)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    local e4=e3:Clone()
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e4:SetCondition(function (e) return s.qphandcon(e) and Duel.IsMainPhase() end)
    c:RegisterEffect(e4)
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FALSE)

end
s.listed_names={CARD_REVENGEANCE} --Revengeance of the Desperados

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end

function s.thfilter(c)
    return c:IsCode(CARD_REVENGEANCE) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp, id)==0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.RegisterFlagEffect(tp, id, RESET_CHAIN, 0, 1)

end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
        local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
        if #dg>0 then
            Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
        end
    end
    --You cannot Special Summon cards with this card's name for the rest of this turn.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return c:IsCode(id) end)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
    
end

function s.qphandcon(e)
    return Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)>9
end




function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsLocation(LOCATION_MZONE) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1 then
       local b1=Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)>14
       if b1 then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetCode(511002961)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
        e2:SetReset(RESET_CHAIN)
        c:RegisterEffect(e2)
       end

       	local fusion_params = {nil,nil,nil,nil,Fusion.ForcedHandler,exactcount=2}
        if Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
		end


    end

end
