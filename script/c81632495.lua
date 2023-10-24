--Dual Space Yggdrago (CT)
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
    --Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,SPACE_YGGDRAGO,2)

    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.drcost)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)


end


function s.cfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToDeck()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local num=Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,num,nil) end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local num=Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_MZONE, nil)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,num,num,nil)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) then
        local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(num)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

    if num==3 then
        c:AddPiercing(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    end
    end

    
end
