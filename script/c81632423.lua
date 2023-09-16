--Victim Barrier (CT)
local s,id=GetID()
function s.initial_effect(c)
	--change target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCategory(CATEGORY_RECOVER)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCondition(s.healcon)
    e3:SetCost(aux.bfgcost)
	e3:SetOperation(s.healop)
	c:RegisterEffect(e3)
end

function s.healcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return ep==tp and (a:IsCode(100000224) or (d and d:IsCode(100000224))) and ev>0
end
function s.healop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,ev,REASON_EFFECT)
end


function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,Duel.GetAttackTarget()) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,Duel.GetAttackTarget())
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Duel.ChangeAttackTarget(tc)
        Duel.CalculateDamage(Duel.GetAttacker(),tc)
		if tc:GetCounter(0x109a)>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_DAMAGE_STEP_END)
			e1:SetOperation(s.ctop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if a and a:IsRelateToBattle() then
		a:AddCounter(0x109a,1)
	end
end
