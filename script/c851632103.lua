--Impatient Roleplayer
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain(true)
	return ep==tp and ch>0 and Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)==tp
		and ( Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT):GetHandler():IsNormalSpell() or  Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT):GetHandler():IsNormalTrap())
end
function s.desfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local tc=Duel.SelectMatchingCard(tp, s.desfilter, tp,LOCATION_MZONE, LOCATION_MZONE, 1,1,false,nil)
    if tc then Duel.Destroy(tc, REASON_EFFECT) end
	if e:IsActiveType(TYPE_SPELL+TYPE_TRAP) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		c:CancelToGrave(false)
	end
end
