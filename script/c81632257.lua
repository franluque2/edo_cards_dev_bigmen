--Food Cemetery (CT)
local s,id,alias=GetID()
function s.initial_effect(c)
    alias = c:GetOriginalCodeRule()

    c:SetUniqueOnField(1,0,alias)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCategory(CATEGORY_LEAVE_GRAVE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSetCard(0x512) and not c:IsReason(REASON_RETURN)
end
function s.afilter(c)
	return c:IsSetCard(0x512) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	local ct=#g
	if chk==0 then return true end

    Duel.SelectTarget(tp, s.filter, tp, LOCATION_GRAVE, 0, 0, 3)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)

	if #g>0 then
		Duel.Overlay(c,g)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)>c:GetOverlayCount() then
		local sg=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_ONFIELD,0,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
