--Beautiful Bird Burst (CT)
local s,id=GetID()
function s.initial_effect(c)
	--destroy equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_EQUIP)
    e1:SetCondition(s.actcond)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_WINGEDBEAST) and c:IsFaceup()
end
function s.actcond(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local tc=rc:GetEquipTarget()
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and tc:IsControler(1-tp)
end
function s.dmgfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0 and c:GetEquipCount()>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dmgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local tc=Duel.SelectMatchingCard(tp,s.dmgfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.Damage(p,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
