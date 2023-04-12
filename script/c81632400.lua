--Rage of the Forbidden One (CT)
local s,id=GetID()
function s.initial_effect(c)

    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
    e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)

    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1})
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	
end

function s.exodiafilter(c)
    return (c:IsSetCard(SET_FORBIDDEN_ONE)) and c:IsFaceup()
end

function s.filternegate(c)
	return c:IsFaceup() and (c:IsType(TYPE_EFFECT) or c:IsSpellTrap()) and not c:IsDisabled()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local exg=Duel.GetMatchingGroup(s.exodiafilter, tp,LOCATION_ONFIELD+LOCATION_GRAVE, 0, nil)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.filternegate(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filternegate,tp,0,LOCATION_ONFIELD,1,nil) and #exg>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local num=exg:GetClassCount(Card.GetCode)
	Duel.SelectTarget(tp,s.filternegate,tp,0,LOCATION_ONFIELD,1,num,nil)
end

function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetTargetCards(e)
	if #dg==0 then return end
	local c=e:GetHandler()
	for tc in dg:Iter() do
		if (tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER) then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			--Negate its effects
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end

function s.exodfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0xde) or c:IsCode(13893596))
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ( Duel.GetAttacker() and s.exodfilter(Duel.GetAttacker()) or (Duel.GetAttackTarget() and s.exodfilter(Duel.GetAttackTarget())))
		and rp~=tp
        and Duel.IsChainNegatable(ev) and e:GetHandler():GetFlagEffect(id)==0
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
