--White Panda with Dark Tail (CT)
--ペンギン・ソルジャージ
--Penguin Soljersey
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Return 1 card on the field to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.tgfilter(c)
	return c:IsLevelBelow(6) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_BEAST)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_MZONE,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement:
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==0 then return end
	--Effect:
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_MZONE,2,2,nil)
	if #tc>0 then
		tc=tc:AddMaximumCheck()
		Duel.HintSelection(tc,true)
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
    --Prevent non-DARK Spellcaster from attacking
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	end
end

function s.atktg(e,c)
	return not (c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_WATER))
end