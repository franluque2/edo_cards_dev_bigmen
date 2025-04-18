--Graydle Assault
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCondition(s.eqpcond)
	e1:SetTarget(s.eqptg)
	e1:SetOperation(s.eqpop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.SelfBanishCost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop2)
	c:RegisterEffect(e2)
end
s.listed_series={0xd1}

function s.eqpcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xd1),tp,LOCATION_MZONE,0,1,nil)
end
function s.eqfilter(c,eqtg,tp)
	return c:IsSetCard(0xd1) and c:IsLevel(3) and c:CheckUniqueOnField(tp)
end
function s.cfilter(c,tp,e)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND,0,1,nil,c,tp) and aux.CheckStealEquip(c,e,tp)
end
function s.eqptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_MZONE,1,nil,tp,e) end
	Duel.SelectTarget(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil,tp,e)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND)
end
function s.eqpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then return end 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND,0,1,1,nil,tc,tp)
	if #g>0 then
		Duel.Equip(tp,g:GetFirst(),tc)

        local tc2=g:GetFirst()

        local c=e:GetHandler()

        if  aux.CheckStealEquip(tc,e,tp) and Duel.Equip(tp,tc2,tc,true) then
            		--Add Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		tc2:RegisterEffect(e1)
		--control
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e2)
		--Destroy
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_LEAVE_FIELD_P)
		e3:SetOperation(s.checkop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc2:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e4:SetCode(EVENT_LEAVE_FIELD)
		e4:SetOperation(s.desop)
		e4:SetReset(RESET_EVENT+RESET_OVERLAY+RESET_TOFIELD)
		e4:SetLabelObject(e3)
		tc2:RegisterEffect(e4)

        end
	end
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetEquipTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end


function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1,0)
            e1:SetValue(1)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
	end
end