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
end
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0x1034,fc,0,tp)
end
function s.spcostfilter(c)
	return c:IsCode(81632867) and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_SZONE)
		or ((c:IsMonsterCard() and c:GetCounter(0x1107)>0) and c:GetOwner()~=c:GetControler()))
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_SZONE)==1
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_SZONE,0,nil)
	if #g==g:FilterCount(Card.IsLocation,nil,LOCATION_SZONE) then return false end
	return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_SZONE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.SendtoGrave(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
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
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
		tc:RegisterEffect(e1)
	end
end
