--Fire Jinn the Flame Genie of the Lamp
Duel.LoadScript ("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,511009005, 97590747)
	Fusion.AddProcMix(c,true,true,511009005, 99510761)

	--fusion success
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--cannot be attacked
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)

	--handes
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCondition(s.hdcon)
	e5:SetTarget(s.hdtg)
	e5:SetOperation(s.hdop)
	c:RegisterEffect(e5)
	
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetLP(1-tp)>0
end

function s.atlimit(e,c)
	return c:IsLevelBelow(4) and c:IsCTLamp() and c:IsType(TYPE_EFFECT)
end

function s.spfilter(c,e,tp)
	return c:IsCTLamp() and c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if 	Duel.Damage(1-tp,600,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0  then

	if Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.spfilter, tp, LOCATION_HAND, 0, 1,1,false,nil,e,tp)
		if tc then
			Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
		end
	end
	end
end

function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
end
function s.tributefilter(c)
	return c:IsCTLamp() and c:IsType(TYPE_EFFECT) and c:IsReleasable() and c:IsLevelBelow(4)
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tributefilter, tp, LOCATION_MZONE, 0, 1, nil) end
	local tc=e:GetHandler():GetReasonCard()
	if tc:IsRelateToBattle() then
		local sg=Duel.SelectReleaseGroupCost(tp,s.tributefilter,1,1,false,nil,nil)
		Duel.Release(sg,REASON_COST)
	
		Duel.SetTargetCard(tc)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
	end
end

function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	if Duel.Destroy(tc, REASON_EFFECT) then
		Duel.Damage(1-tp, 600, REASON_EFFECT)
	end
end


