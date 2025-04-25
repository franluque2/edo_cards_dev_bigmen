--Rainbow Snared Dragon (CT)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeFusionSummoned()
	--Fusion Materials: 7 Crystal Beast monsters with different names
    Fusion.AddProcMixN(c,true,true,s.ffilter,7)
	--Alternative Summon Procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.hspcon)
	e0:SetTarget(s.hsptg)
	e0:SetOperation(s.hspop)
	c:RegisterEffect(e0)
	--Place 1 monster from the field in the Spell & Trap Zone as a Continuous Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
    --Gain 1000 ATK for each "Crystal Beast" monster sent to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0x1034,fc,0,tp)
end
function s.hspfilter(c)
	return c:IsMonsterCard() and c:IsFaceup() and c:IsAbleToGraveAsCost() and c:GetCounter(0x1107)>0
end
function s.hspcon(e,c)
	if not c then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_STZONE,0,2,nil)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_STZONE,0,2,2,true,nil)
	if not g then return false end
	g:KeepAlive()
	e:SetLabelObject(g)
	return true
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end
function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsFaceup() and Duel.GetLocationCount(p,LOCATION_SZONE)>0 and not c:IsForbidden() and c:CheckUniqueOnField(p)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.plfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.plfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	local p=tc:GetOwner()
	if Duel.GetLocationCount(p,LOCATION_SZONE)==0 then
		Duel.SendtoGrave(tc,REASON_RULE,nil,PLAYER_NONE)
	elseif tc:CheckUniqueOnField(p) and Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
        tc:AddCounter(0x1107,1)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():HasFlagEffect(id) then return false end
	return aux.StatChangeDamageStepCondition()
end
function s.atkfilter(c)
	return c:IsMonsterCard() and c:IsFaceup() and c:IsAbleToGraveAsCost() and c:GetCounter(0x1107)>0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_SZONE,0,nil)
	if chk==0 then return #g>0 and not g:IsContains(e:GetHandler()) end
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(#g)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel()*1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end