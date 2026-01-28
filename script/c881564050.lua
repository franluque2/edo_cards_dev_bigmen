--I am the Bone of My Sword
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
    return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)<(1+WbAux.GetFatedChantUses(tp)) and e:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_CONJURE,nil,1,tp,0)
    Duel.SetTargetPlayer(1-tp)
end

function s.filterfunc(c)
    return not WbAux.IsIgnoreStaple(c)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local g=Duel.GetMatchingGroup(Card.IsMonster, p, LOCATION_HAND|LOCATION_DECK, 0, nil)
    if #g>0 then
        local g2=g:Filter(s.filterfunc, nil)
        local unique_cards_map = {}
        local unique_cards = {}
        for card in g2:Iter() do
            local code = card:GetCode()
            if not unique_cards_map[code] then
                table.insert(unique_cards, card)
                unique_cards_map[code] = true
            end
        end
        g2=Group.FromCards(table.unpack(unique_cards))
        if #g2>0 then
            local tc=g2:RandomSelect(1-p,9)
            local g3=Group.CreateGroup()
            for card in tc:Iter() do
                local token=Duel.CreateToken(1-p, card:GetOriginalCode())
                if token then
                    g3:AddCard(token)
                end
            end
            Duel.Hint(HINT_SELECTMSG, 1-p, HINTMSG_ATOHAND)
            Duel.ConfirmCards(1-p, g3)
            local tg=g3:Select(1-p, 1, 1, nil)
            if #tg>0 then
                Duel.SendtoHand(tg, 1-p, REASON_EFFECT)
                Duel.ConfirmCards(p, tg)
            end
            g3:RemoveCard(tg:GetFirst())
            if #g3>0 then
                Duel.BreakEffect()
                Duel.SendtoDeck(g3, 1-p, SEQ_DECKSHUFFLE, REASON_EFFECT)
            end

        end
    end
    WbAux.IncreaseFatedChantStatus(c,tp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		if c:IsHasEffect(EFFECT_CANNOT_TO_HAND) then return end
		c:CancelToGrave()
		Duel.SendtoHand(c, tp, REASON_EFFECT)
	end
    Duel.ShuffleHand(tp)

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