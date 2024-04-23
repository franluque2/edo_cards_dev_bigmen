--Cat Food (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--lv change
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,{id,0})
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end


function s.tdfilter(c,tp)
	return (c:IsSetCard(0x1538) or c:IsSetCard(0x150e)) and (c:IsAbleToGrave())
end

function s.filter(c)
	return c:IsSetCard(0x150e)
end

function s.filter2(c)
	return c:IsSetCard(0x1538)
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tdfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	if tc:IsSetCard(0x1538) and tc:IsLocation(LOCATION_GRAVE) then
		Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,0x13,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
        end
	elseif tc:IsSetCard(0x150e) and tc:IsLocation(LOCATION_GRAVE)
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.filter2,tp,0x13,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)
        end
	end
end

function s.lfilter(c)
	return c:IsFaceup() and c:HasLevel() and (c:IsSetCard(0x150e) or c:IsSetCard(0x1538))
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.lfilter,tp,LOCATION_MZONE,0,1,3,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,4)
	Duel.SetTargetParam(lv)
end
function s.lvfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.lvfilter,nil,e)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end