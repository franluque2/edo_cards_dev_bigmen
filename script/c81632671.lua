--Elisha the Lovely Bisque Doll (CT)
local s,id=GetID()
function s.initial_effect(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
    --cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    --control
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end
function s.val(e,c)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,0x2517)
	local atk=0
	while #g>=4 and g:GetClassCount(Card.GetCode)>=4 do
		local g1=g:GetFirst()
		local g2=g:GetNext()
		while g2:GetCode()==g1:GetCode() do
			g2=g:GetNext()
		end
		local g3=g:GetNext()
		while g3:GetCode()==g1:GetCode() or g3:GetCode()==g2:GetCode() do
			g3=g:GetNext()
		end
		local g4=g:GetNext()
		while g4:GetCode()==g1:GetCode() or g4:GetCode()==g2:GetCode() or g4:GetCode()==g3:GetCode() do
			g4=g:GetNext()
		end
		if g1 and g2 and g3 and g4 then
			g:Sub(Group.FromCards(g1,g2,g3,g4))
			atk=atk+1000
		end
	end
	return atk
end
function s.filter(c)
	return c:IsCode(511001466) and c:IsControlerCanBeChanged()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_GRAVE,0,12,nil,0x2517)
end