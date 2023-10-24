--Deep Space Impact (CT)
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

end

function s.putbackmonfilter(c)
    return c:IsRace(RACE_CYBERSE) and c:IsAbleToDeck()
end

function s.fusordeepwarfilter(c)
    return c:IsCode(81632491,CARD_FUSION) and c:IsAbleToDeck()
end


function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRace(RACE_CYBERSE) and tc:IsPosition(POS_FACEUP) and tc:IsLevelAbove(5)
        and Duel.IsExistingMatchingCard(s.putbackmonfilter, tp, LOCATION_GRAVE, 0, 3, nil)
        and Duel.IsExistingMatchingCard(s.fusordeepwarfilter, tp, LOCATION_GRAVE, 0, 1, nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttackTarget()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local tc=Duel.GetAttacker()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
        local mons=Duel.SelectMatchingCard(tp, s.putbackmonfilter,tp, LOCATION_GRAVE, 0, 3,3,false,nil)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
        local spell=Duel.SelectMatchingCard(tp, s.fusordeepwarfilter,tp, LOCATION_GRAVE, 0, 1,1,false,nil)

        mons:Merge(spell)

        if mons and Duel.SendtoDeck(mons, tp,SEQ_DECKTOP, REASON_EFFECT) then
            Duel.SortDecktop(tp,tp,4)
            Duel.BreakEffect()
            Duel.Destroy(tc, REASON_EFFECT)
        end

	end
end
