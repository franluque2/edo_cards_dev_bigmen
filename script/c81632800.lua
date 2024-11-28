--Not The World
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_COIN|CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
    e1:SetCost(s.cost)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_COST)>0 then
	local res=Duel.TossCoin(tp,1)
	if res==COIN_HEADS then
        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
        if #g>0 then
            ct=Duel.Destroy(g,REASON_EFFECT)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
            e1:SetValue(1000)
            c:RegisterEffect(e1)
        end
	elseif res==COIN_TAILS then
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		Duel.Destroy(g,REASON_EFFECT)
		local dg=Duel.GetOperatedGroup()
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end
end
function s.desfilter(c)
	return c:IsAttackPos() and (c:IsLevelBelow(8) or c:IsRankBelow(8) or c:IsLinkBelow(4)) and c:IsNotMaximumModeSide()
end
function s.costfilter(c)
	return (c.toss_coin and c:IsMonster()) or (c:IsMonster() and c:IsDefense(c:GetAttack()))
end