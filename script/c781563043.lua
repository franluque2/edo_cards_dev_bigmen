--Numeron Storm
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMEROUNIOUS}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NUMEROUNIOUS),tp,LOCATION_MZONE,0,1,nil)
end

function s.xyzfilter(c)
    return c:IsType(TYPE_XYZ) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsSpellTrap() end
    local ct=Duel.GetMatchingGroupCount(s.xyzfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_SZONE,1,nil)  end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_SZONE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*4000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		if Duel.Destroy(tg,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,#tg*4000,REASON_EFFECT)
		end
	end
end