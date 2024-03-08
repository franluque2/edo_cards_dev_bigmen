--Ancient City (CT)
local s,id=GetID()
Duel.LoadScript("c420.lua")
function s.initial_effect(c)
    --Activation Search
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    --Special Summon 1 "Ancient Dragon"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)

    --End Phase Special Summon
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(s.checkop)
	c:RegisterEffect(e3,0)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

function s.costfilter(c,code,ft)
	return c:IsFaceup() and c:IsCode(code) and c:IsAbleToGraveAsCost() and (not ft or ft>0 or c:GetSequence()<5) 
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil,TYPE_SPELL+TYPE_CONTINUOUS)
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil,TYPE_SPELL+TYPE_CONTINUOUS)
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil,TYPE_SPELL+TYPE_CONTINUOUS,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil,TYPE_SPELL+TYPE_CONTINUOUS)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil,TYPE_SPELL+TYPE_CONTINUOUS)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g3=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil,TYPE_SPELL+TYPE_CONTINUOUS,ft)
	g1:Merge(g2)
	g1:Merge(g3)
	Duel.SendtoGrave(g1,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(511000128) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
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
function s.thfilter(c)
	return c:IsCode(511000123, 511000124, 511000125) and c:IsAbleToHand()
end
function s.Dragon(c)
	return c:IsCode(511000128)
end

function s.chkfilter(c,tp)
	return c:IsCode(511000128) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.chkfilter,1,nil,tp) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.filter(c,e,tp)
	return c:IsCode(511000128) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
