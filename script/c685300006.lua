--Tribute Trade
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 monster you control; Tribute it, and if you do, add 1 monster from your Deck to your hand with a different level than the Tributed monster. You can only activate 1 "Tribute Trade" per turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_RELEASE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.tg)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)

end

function s.thfilter(c,level)
    return c:IsMonster() and c:GetLevel()~=level and c:IsAbleToHand()
end


function s.futributefilter(c,tp)
    return c:IsReleasableByEffect() and c:HasLevel() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.futributefilter(chkc,tp) end
    if chk==0 then return true end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectTarget(tp,s.futributefilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    Duel.HintSelection(g)
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end