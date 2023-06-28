--Exchanging Notes (CT)
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_ADD_SETCODE)
    e3:SetValue(0x526)
    e3:SetRange(LOCATION_ALL)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
    c:RegisterEffect(e3)
end
s.listed_series={0x526}
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x526),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		local og=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
        local g=og:Select(tp,2,2,nil)
		Duel.SendtoHand(g,1-tp,REASON_EFFECT)
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		Duel.ConfirmCards(tp,hg)
		local sg=hg:Select(tp,2,2,nil)
		Duel.SendtoHand(sg,tp,REASON_EFFECT)
		local gc=sg:GetFirst()
		while gc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_SETCODE)
            e1:SetValue(0x526)
			e1:SetReset(RESET_CONTROL)
			gc:RegisterEffect(e1)
			gc=sg:GetNext()
		end
	end
end