--Hunting Net (CT)
local s,id=GetID()
function s.initial_effect(c)
	--place on spell field on return to hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--place on spell field on return to extra
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
	--Shuffle Traps up to the number of Prey Counters
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.rmvtg)
	e3:SetOperation(s.rmvop)
	c:RegisterEffect(e3)
end
s.listed_names={511004336}
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_ONFIELD)
end

function s.backrowfilter(c)
	return (c:IsCode(511004336) or c:IsCode(511004328)) and c:IsSSetable()
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	return ex and tg~=nil and tc+tg:FilterCount(s.filter,nil)-#tg>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ((Duel.GetLocationCount(tp,LOCATION_SZONE)>0) or (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0)) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local og=tg:Filter(s.filter,nil)
	local oc=og:GetFirst()
	while oc and ((Duel.GetLocationCount(tp,LOCATION_SZONE)>0) or (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0)) do

		if (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
			Duel.MoveToField(oc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
			oc:AddCounter(0x1107,1)
		else
			Duel.MoveToField(oc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			oc:AddCounter(0x1107,1)
		end

		oc=og:GetNext()
	end
end



function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOEXTRA)
	return ex and tg~=nil and tc+tg:FilterCount(s.filter,nil)-#tg>0
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ((Duel.GetLocationCount(tp,LOCATION_SZONE)>0) or (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0)) end
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOEXTRA)
	local og=tg:Filter(s.filter,nil)
	local oc=og:GetFirst()
	while oc and ((Duel.GetLocationCount(tp,LOCATION_SZONE)>0) or (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0)) do

		if (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
			Duel.MoveToField(oc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
			oc:AddCounter(0x1107,1)
		else
			Duel.MoveToField(oc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			oc:AddCounter(0x1107,1)
		end

		oc=og:GetNext()
	end
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=1 then return end
	Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
end

function s.filter2(c)
	return c:IsCode(81632867, 81632122, 511001382, 511001381)
end
