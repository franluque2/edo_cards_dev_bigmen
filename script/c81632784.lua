--Beautiful Bird Waltz (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Your attacked monster gains 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsAttribute(ATTRIBUTE_WIND)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttackTarget()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,3,REASON_COST)<1 then return end
    local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(s.filter,nil)
	--Effect
	local tc=Duel.GetAttackTarget()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
    if ct==3 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		if #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end

function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLocation(LOCATION_GRAVE)
end
