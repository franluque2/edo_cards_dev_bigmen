--Iceberg Ocean (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--Def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetCondition(s.indcon)
	e2:SetTarget(s.tg)
	e2:SetValue(0)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(function(e) return Duel.IsTurnPlayer(e:GetHandlerPlayer()) end)
	e3:SetTarget(function(e,c) return c:IsType(TYPE_TOKEN) end)
	e3:SetValue(s.immval)
	c:RegisterEffect(e2)

    --actlimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(1)
	e4:SetCondition(s.actcon)
	c:RegisterEffect(e4)
end

function s.thfilter(c)
	return c:IsCode(511001669, 511005599) and c:IsAbleToHand()
end

function s.deffilter(c)
	return c:IsFaceup() and (c:IsLevelAbove(10) or c:IsRankAbove(10))
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.tg(e,c)
	return c:GetPosition()==POS_FACEUP_DEFENSE
end

function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.deffilter,e:GetOwnerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.immval(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end

function s.actfilter(c,tp)
	return c and c:IsFaceup() and c:IsRankAbove(10) and c:IsMonster() and c:IsControler(tp)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return s.actfilter(Duel.GetAttacker(),tp) or s.actfilter(Duel.GetAttackTarget(),tp)
end