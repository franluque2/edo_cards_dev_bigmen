--Hundred Eyes Dragon (CT)
local s,id=GetID()
function s.initial_effect(c)
	c:AddSetcodesRule(id,false,0x601)
	--dark synchro summon
	c:EnableReviveLimit()
	Synchro.AddDarkSynchroProcedure(c,Synchro.NonTuner(nil),nil,8)
	--copy

	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetDescription(aux.Stringid(id, 1))
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_ADJUST)
	e4:SetCondition(s.cpcon)
	e4:SetTarget(s.cptg)
	e4:SetOperation(s.cpop)
	c:RegisterEffect(e4)

	--search
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_LEAVE_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)


	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetRange(LOCATION_MZONE)
	ge1:SetCode(RESET_EVENT+RESETS_STANDARD)
	ge1:SetCountLimit(1)
	ge1:SetCondition(s.resetop)
	c:RegisterEffect(ge1)
end

s.name_list={}
s.name_list[0]={}
s.name_list[1]={}

function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.name_list[0]={}
	s.name_list[1]={}
	return false
end

if not table.includes then
	--binary search
	function table.includes(t,val)
		if #t<1 then return false end
		if #t==1 then return t[1]==val end --saves sorting for efficiency
		table.sort(t)
		local left=1
		local right=#t
		while left<=right do
			local middle=(left+right)//2
			if t[middle]==val then return true
			elseif t[middle]<val then left=middle+1
			else right=middle-1 end
		end
		return false
	end
end

function s.inffilter(c,tp)
	return c:IsSetCard(0xb) and c:IsMonster() and not table.includes(s.name_list[tp],c:GetOriginalCode())
end

function s.cpcon(e, tp, eg, ep, ev, re, r, rp, chk)
	return Duel.IsExistingMatchingCard(s.inffilter, tp, LOCATION_GRAVE, 0, 1, nil, tp)
end
function s.cptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return true
	end
	local bc = Duel.SelectMatchingCard(tp, s.inffilter, tp, LOCATION_GRAVE, 0, 1, 1, nil,tp):GetFirst()
	Duel.SetTargetCard(bc)
	e:SetLabelObject(bc)
end

function s.cpop(e, tp, eg, ep, ev, re, r, rp)
	local tc = e:GetLabelObject()
	if tc and e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():CopyEffect(tc:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD, 1)
		table.insert(s.name_list[tp],tc:GetOriginalCode())
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end

function s.immofilter(c)
	return c:IsSetCard(0x21) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.immofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.immofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
