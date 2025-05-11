--P.K. King of Dark Illusion (CT)
local s,id=GetID()
function s.initial_effect(c)
	--summon with 1 tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.nscon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
    --actlimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
    --increase ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end

function s.lv5plusmonfilter(c)
	return c:IsCode(312000143) and c:IsFaceup()
end
function s.nscon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.lv5plusmonfilter,0,LOCATION_ONFIELD,0,1,nil)
		and Duel.CheckTribute(c,1)
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON|REASON_MATERIAL)
end
function s.actcon(e)
	return (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()) and 
    Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,312000143),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetAttackTarget()~=nil then
		return (Duel.GetAttacker():IsControler(tp) and (Duel.GetAttacker():IsRace(RACE_FIEND) and Duel.GetAttacker():IsAttribute(ATTRIBUTE_DARK) and Duel.GetAttacker():IsType(TYPE_NORMAL)))
		or (Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp) and (Duel.GetAttacker():IsRace(RACE_FIEND) and Duel.GetAttacker():IsAttribute(ATTRIBUTE_DARK) and Duel.GetAttacker():IsType(TYPE_NORMAL)))
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	if a:IsControler(1-tp) then a,d=d,a end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE_CAL)
	e1:SetValue(a:GetBaseDefense()/2)
	a:RegisterEffect(e1)
end