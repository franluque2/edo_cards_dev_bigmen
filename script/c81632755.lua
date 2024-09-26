--Dull Manga (CT)
--藍の牢獄
--Indigo Prison
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
    e1:SetTarget(s.destg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,1,nil) end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return ep==1-tp and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) end
	tc:CreateEffectRelation(e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsAbleToGraveAsCost),tp,LOCATION_MZONE,0,1,1,nil)
	g=g:AddMaximumCheck()
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct>0 then
        local tc=eg:GetFirst()
        if tc and tc:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(-2000)
            e1:SetReset(RESETS_STANDARD_PHASE_END)
            g:GetFirst():RegisterEffect(e1)
        end
        if tc:IsPreviousLocation(LOCATION_EXTRA) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.tdfilter),tp,0,LOCATION_MZONE,1,1,nil)
            if #g==0 then return end
            g=g:AddMaximumCheck()
            Duel.HintSelection(g,true)
            Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
	end
end

