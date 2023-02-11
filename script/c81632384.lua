--Metalbolic Storm (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,{id,0})
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetLabelObject(e1)
		ge1:SetOperation(s.damop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)


end
function s.chkfilter(c,tp,re)
	return c:IsMonster() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and (c:GetReason()&0x41)==0x41 and re:GetOwner():IsSetCard(0x1512)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g1=eg:Filter(s.chkfilter,nil,tp,re)
	local g2=eg:Filter(s.chkfilter,nil,1-tp,re)
	if #g1>0 then
		local sum=g1:GetSum(Card.GetAttack)/2
		s[tp]=s[tp]+sum
	end
	if #g2>0 then
		local sum=g2:GetSum(Card.GetAttack)/2
		s[1-tp]=s[1-tp]+sum
	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s[tp]>0 or s[1-tp]>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if s[tp]>0 then
		Duel.Damage(tp,s[tp],REASON_EFFECT)
	end
	if s[1-tp]>0 then
		Duel.Damage(1-tp,s[1-tp],REASON_EFFECT)
	end
end

function s.filter2(c)
	return c:IsFaceup() and c:IsCode(511001086)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_SZONE,0,1,nil) and Duel.GetTurnPlayer()==tp end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter2,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end