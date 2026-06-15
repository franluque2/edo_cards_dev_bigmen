--Nightmare Penguin of the Virtual World
local s, id = GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)

    -- Once per turn, if a card(s) your opponent controls leaves the field due to your card effect: you can activate one of the following effects:
    --● Add 1 "Penguin" card from your Deck to your hand, then you can Set 1 monster from your hand.
    --● Add copies of those cards to your Hand/Extra Deck.

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.flipcon)
    e1:SetTarget(s.fliptg)
    e1:SetOperation(s.flipop)
    c:RegisterEffect(e1)
end
s.listed_series={SET_PENGUIN}

function s.controlfilter(c,tp)
    return c:IsControler(tp)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.controlfilter, 1, nil, 1-tp) and re and re:GetHandler():IsControler(tp)
end

function s.tohandfilter(c)
    return c:IsSetCard(SET_PENGUIN) and c:IsAbleToHand()
end

function s.fliptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.tohandfilter, tp, LOCATION_DECK, 0, 1, nil)
	local b2=#eg>0
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
        Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    else
        e:SetCategory(CATEGORY_TOHAND)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,#eg,0,0)
    end
end

function s.setmonsterfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false, POS_FACEDOWN_DEFENSE)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.tohandfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,g)
            if Duel.IsExistingMatchingCard(s.setmonsterfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.SelectYesNo(tp, aux.Stringid(id,9)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
                local sg=Duel.SelectMatchingCard(tp,s.setmonsterfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
                if #sg>0 then
                    Duel.SpecialSummon(sg, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
                    Duel.ConfirmCards(1-tp,sg)
                end
            end
        end
    else
        local g=Group.CreateGroup()
        local g2=Group.CreateGroup()
        for tc in eg:Iter() do
            local token=Duel.CreateToken(tp, tc:GetOriginalCode())
            g:AddCard(token)
        end
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end