--Catnip Turbine (CT)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--Atk up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(1200)
	c:RegisterEffect(e3)
	--cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetValue(s.vala)
	c:RegisterEffect(e4)

    --Destroy an opponent's attacking monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
function s.filter(c)
	return (c:IsSetCard(0x150e) or c:IsSetCard(0x1538))
end
function s.vala(e,c)
	return c:GetControler()~=e:GetHandlerPlayer()
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,ac,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
    if ac:IsAttackPos() and ac:IsRelateToBattle() then
        Duel.ChangePosition(ac,POS_FACEUP_DEFENSE)
    end
end