--Uninteresting Manga You Wouldn't Read Again
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp) and Duel.IsExistingMatchingCard(s.Manga,tp,LOCATION_GRAVE,0,1,nil)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,nil) end
end
--Make 1 dino monster you control gain ATK
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    --Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.Manga,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g,true)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	--Effect
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(4600)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Cannot be destroyed by opponent's card effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3060)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
    if Duel.IsExistingMatchingCard(s.Manga,tp,0,LOCATION_GRAVE,1,nil) 
    and Duel.IsPlayerCanDraw(tp,5) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.BreakEffect()
    Duel.Draw(tp,5,REASON_EFFECT)
end
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
function s.Manga(c)
	return c:IsCode(81632751, 81632755)
end