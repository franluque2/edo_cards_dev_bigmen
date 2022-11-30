--Scrubbing Bridge (CT)
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
    e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	Duel.DiscardDeck(tp,1,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)

    local tc1=Duel.GetDecktopGroup(tp, 1)
    local tc2=Duel.GetDecktopGroup(1-tp, 1)

	local d1=Duel.Draw(tp,1,REASON_EFFECT)
	local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
	if d1==0 or d2==0 then return end

    Duel.ConfirmCards(1-tp, tc1)
    Duel.ConfirmCards(tp, tc2)
    
    if tc1:GetFirst():IsType(TYPE_MONSTER) and
        tc1:GetFirst():IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false, POS_FACEUP_DEFENSE) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.SpecialSummon(tc1, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end

    
    if tc2:GetFirst():IsType(TYPE_MONSTER) and
        tc2:GetFirst():IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, 1-tp, false, false, POS_FACEUP_DEFENSE) and Duel.SelectYesNo(1-tp, aux.Stringid(id, 0)) then

            Duel.SpecialSummon(tc2, SUMMON_TYPE_SPECIAL, 1-tp, 1-tp, false, false, POS_FACEUP_DEFENSE)

        end

end
