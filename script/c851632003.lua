--Dark Mother of Dredges
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--Add this to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.gspcon)
	e2:SetTarget(s.gsptg)
	e2:SetCost(s.gspc)
	e2:SetOperation(s.gspop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ABYSSAL_DREDGE}

function s.tribfilter(c)
	return c:IsCode(CARD_ABYSSAL_DREDGE) and c:IsReleasableByEffect()
end

function s.gspc(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tribfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.tribfilter,1,1,false,nil,nil)
	Duel.Release(sg,REASON_COST)
end

function s.gspconfilter(c,tp)
	return c:IsFaceup() and c:IsCode(CARD_ABYSSAL_DREDGE) and c:IsSummonPlayer(tp)
end
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gspconfilter,1,nil,tp)
end
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c, tp, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, c)
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return WbAux.CanPlayerSummonDredge(tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if WbAux.CanPlayerSummonDredge(tp) then
		WbAux.SpecialSummonDredge(tp)
	end
end