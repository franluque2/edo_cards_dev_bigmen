--Unknown to Death nor known to Life

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
    return Duel.GetCustomActivityCount(id-3,tp,ACTIVITY_CHAIN)<(1+WbAux.GetFatedChantUses(tp)) and e:IsHasType(EFFECT_TYPE_ACTIVATE)
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

function s.filterfunc2(c)
    return c:IsTrap()
end


function s.activate(e,tp,eg,ep,ev,re,r,rp)

    
    WbAux.IncreaseFatedChantStatus(c,tp)
    local c=e:GetHandler()

    --Add a copy of every unique Trap card in your opponent's possession to your deck, then choose one to add to your hand
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local g=Duel.GetMatchingGroup(s.filterfunc2,p,LOCATION_ALL,0,nil)
    local seen = {}
    local cardstoconjure={}
	for card in g:Iter() do
		local code = card:GetOriginalCode()
		if not seen[code] then
			table.insert(cardstoconjure, code)
			seen[code] = true
		end
	end
    local addedcards=Group.CreateGroup()
    for _, code in ipairs(cardstoconjure) do
        local token=Duel.CreateToken(tp,code)
        Duel.SendtoDeck(token,nil,SEQ_DECKTOP,REASON_EFFECT)
        addedcards:AddCard(token)
    end

    if #addedcards~=0 then
        Duel.ShuffleDeck(tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=addedcards:Select(tp,1,1,nil)
        Duel.BreakEffect()
        Duel.SendtoHand(sg,nil,REASON_EFFECT)        
    end

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