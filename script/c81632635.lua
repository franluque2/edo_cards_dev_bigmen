--Xyz Coat (CT)
local s,id=GetID()
function s.initial_effect(c)
--indes by effect and battle
local e1=Effect.CreateEffect(c)
e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetCountLimit(1,{id,0})
e1:SetTarget(s.target)
e1:SetOperation(s.activate)
c:RegisterEffect(e1)

--to deck
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(id,1))
e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DRAW)
e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
e2:SetType(EFFECT_TYPE_QUICK_O)
e2:SetCode(EVENT_FREE_CHAIN)
e2:SetRange(LOCATION_GRAVE)
e2:SetCountLimit(1,{id,1})
e2:SetCondition(s.tdcon)
e2:SetCost(aux.bfgcost)
e2:SetTarget(s.tdtg)
e2:SetOperation(s.tdop)
c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp) and aux.exccon(e)
end
function s.tdfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)>0 and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_EXTRA) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end