--Great Kite of Ninja (CT)
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,511001322))
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(s.distg)
	c:RegisterEffect(e1)
	--disable effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--untargetable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37433748,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,0})
	e4:SetCondition(s.dircon)
	e4:SetCost(s.dircost)
	e4:SetOperation(s.dirop)
	c:RegisterEffect(e4)
    local e6=Effect.CreateEffect(tc)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DIRECT_ATTACK)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(s.dirtg)
	e6:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	c:RegisterEffect(e6)
end

function s.dirfilter(c)
	return c:GetFlagEffect(id)==0
end
function s.dirtg(e,c)
	return not Duel.IsExistingMatchingCard(s.dirfilter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
s.listed_names={511001322}
function s.distg(e,c)
	local ec=e:GetHandler()
	if c==ec or c:GetCardTargetCount()==0 then return false end
	local eq=ec:GetEquipTarget()
	return eq and c:GetCardTarget():IsContains(eq) and c:IsSpellTrap()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler()
	if not ec:GetEquipTarget() or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(ec:GetEquipTarget()) then return end
	Duel.NegateEffect(ev)
end
function s.dircon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.dircost(e,tp,eg,ep,ev,re,r,rp,chk)
	local eq=e:GetHandler():GetEquipTarget()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,nil,eq) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,nil,eq)
	Duel.Release(g,REASON_COST)
end
function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_CANNOT_DISABLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e5)
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.ftarget)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end
function s.ftarget(e,c)
	return c~=e:GetOwner():GetEquipTarget()
end