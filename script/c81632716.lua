--Emissaries of Friendship (CT)
--水神の護符
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.efilter2)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.efilter2)
	e5:SetValue(1)
	c:RegisterEffect(e5)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.accost)
	e3:SetOperation(s.pop)
	c:RegisterEffect(e3)

    
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
function s.indval(e,re,tp)
	return e:GetHandlerPlayer()==1-tp
end

function s.efilter(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.efilter2(e,c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.efilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Reduce damage
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTarget(s.efilter)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.setfilter(c)
	return ((c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsAbleToDeck()) or c:IsCode(02295831) and c:IsAbleToDeck()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.MoveToDeckBottom(tc,nil,0,REASON_EFFECT)
	end
end
