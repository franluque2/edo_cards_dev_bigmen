-- Space Seed Driver(CT)
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
    --Add card to hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.thfilter(c)
    return c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(2) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	if #g>0 then
        if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,g)
            if g:GetFirst():IsCode(SPACE_YGGDRAGO) and Duel.IsPlayerCanDraw(tp) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
                Duel.Draw(tp, 1, REASON_EFFECT)
            end
        end
    end
end

function s.cfilter(c)
    return (c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(5)) and c:IsFaceup()
end