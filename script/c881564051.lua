--Steel is my Body, and Fire is my Blood

Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        local e1=Effect.CreateEffect(c)
        e1:SetCategory(CATEGORY_CONJURE)
        e1:SetType(EFFECT_TYPE_ACTIVATE)
        e1:SetCode(EVENT_FREE_CHAIN)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCondition(s.confunc)
        e1:SetTarget(s.target)
        e1:SetOperation(s.activate)
        c:RegisterEffect(e1)


        WbAux.UpdateFatedChantStatus(c)

    	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not (re:GetHandler():IsCode(CARD_FATED_CHANT)) end)

        WbAux.RegisterStartedInDeckCards()
end
s.listed_names={CARD_FATED_CHANT,id+1}
s.listed_series={SET_FATED}

function s.confunc(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCustomActivityCount(id-1,tp,ACTIVITY_CHAIN)<(1+WbAux.GetFatedChantUses(tp)) and e:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_CONJURE,nil,1,tp,0)
    Duel.SetTargetPlayer(1-tp)
end

function s.filterfunc(c)
    return not WbAux.IsIgnoreStaple(c)
end

function s.sumfilter(c)
	return c:IsSummonable(true,nil)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local g=Duel.GetMatchingGroup(Card.IsFacedown, p, LOCATION_EXTRA, 0, nil)
    if #g>0 then
        Duel.ConfirmCards(1-p, g)
        local num=9
        if #g<num then num=#g end
        Duel.Hint(HINT_SELECTMSG, 1-p, HINTMSG_TODECK)
        local g2=g:Select(1-p, num, num, nil)
        local g3=Group.CreateGroup()
        for card in g2:Iter() do
            local token=Duel.CreateToken(1-p, card:GetOriginalCode())
            if token then
                g3:AddCard(token)
            end
        end
        Duel.SendtoDeck(g3, 1-p, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
    WbAux.IncreaseFatedChantStatus(c,tp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		if c:IsHasEffect(EFFECT_CANNOT_TO_HAND) then return end
		c:CancelToGrave()
		Duel.SendtoHand(c, tp, REASON_EFFECT)
	end
    Duel.ShuffleHand(tp)

    --then immediatly after this resolves you can Normal Summon a monster
    local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
    if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.BreakEffect()
        Duel.ShuffleHand(tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
        local sc=sg:Select(tp,1,1,nil):GetFirst()
        Duel.Summon(tp,sc,true,nil) 
    end


    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return c:GetFlagEffect(CARD_FATED_CHANT-1)>0 and not (c:IsSetCard(SET_FATED)) end)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)

end