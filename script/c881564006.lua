--The Fated Holy Grail
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --When this card is activated: you can add add 1 "Fated" monster from your Deck to your hand as it resolves.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- "Fated" Spirit monsters you control gain 500 ATK.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTarget(function(_,c) return c:IsSetCard(SET_FATED) and c:IsType(TYPE_SPIRIT) end)
    e2:SetValue(500)
    c:RegisterEffect(e2)

    --  If 7 or more "Fated" monsters have been destroyed this Duel: you can banish this card you control and 7 "Fated" Spirit monsters with different names from your GY; replace your opponent's deck with Dregs of Angra Mainyu
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.repcon)
    e3:SetCost(s.repcost)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_FATED}

function s.thfilter(c)
    return c:IsSetCard(SET_FATED) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    return WbAux.DestroyedServantCounter and WbAux.DestroyedServantCounter>=7
end

function s.repcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(function(c) return c:IsSetCard(SET_FATED) and c:IsType(TYPE_SPIRIT) and c:IsAbleToRemoveAsCost() end, tp, LOCATION_GRAVE, 0, nil)
        return e:GetHandler():IsAbleToRemoveAsCost() and g:GetClassCount(Card.GetCode)>=7
    end
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
    local g=Duel.GetMatchingGroup(function(c) return c:IsSetCard(SET_FATED) and c:IsType(TYPE_SPIRIT) and c:IsAbleToRemoveAsCost() end, tp, LOCATION_GRAVE, 0, nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=aux.SelectUnselectGroup(g,e,tp,7,7,aux.dncheck,1,tp,HINTMSG_REMOVE,nil,nil,true)
    Duel.Remove(rg, POS_FACEUP, REASON_COST)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local opdeck=Duel.GetMatchingGroup(aux.TRUE, 1-tp, LOCATION_DECK, 0, nil)
    for card in opdeck:Iter() do
        	Card.Recreate(card, CARD_DREGS_ANGRA_MAINYU, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
    end
end