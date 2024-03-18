--Relativity Field (CT)
local s,id=GetID()
function s.initial_effect(c)
	--activate
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,{id,1})
	c:RegisterEffect(e1)

    --Destruction replacement
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.desreptg)
	c:RegisterEffect(e3)

	--
	s.create_effect(c,0)
	s.create_effect(c,1)
end
function s.create_effect(c,p)
	--lose lp
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(Duel.GetLP(p))
	e2:SetCondition(s.lpcon(p))
	e2:SetOperation(s.lpop(p))
	c:RegisterEffect(e2)
	--lose atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabelObject(e2)
	e4:SetCondition(s.atkcon(p))
	e4:SetOperation(s.atkop(p))
	c:RegisterEffect(e4)
end
function s.lpcon(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return (Duel.GetLP(p)~=e:GetLabel() and not Duel.IsExistingTarget(Card.IsFaceup,p,LOCATION_MZONE,0,1,nil)) or Duel.GetLP(p)>e:GetLabel()
	end
end
function s.lpop(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		e:SetLabel(Duel.GetLP(p))
	end
end
function s.atkcon(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetLP(p)<e:GetLabelObject():GetLabel() and Duel.IsExistingTarget(Card.IsFaceup,p,LOCATION_MZONE,0,1,nil)
	end
end
function s.atkop(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local atk=e:GetLabelObject():GetLabel()-Duel.GetLP(p)
		e:GetLabelObject():SetLabel(Duel.GetLP(p))
		for tc in Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil):Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.thfilter(c)
	return c:IsCode(41386308, 72880377, 511001235, 511000156, 511001232) and c:IsAbleToHand()
end
function s.repfilter(c)
	return c:IsCode(53129443) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,c) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,c)
		Duel.Remove(g:GetFirst(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end