--New Orders - Etheric Thoth
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--xyz
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SPELL_XYZ_MAT)
	e2:SetValue(4)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e3:SetDescription(aux.Stringid(id, 0))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.adtar)
	e3:SetOperation(s.adop)
	c:RegisterEffect(e3)

end
-- Once per turn: You can add 1 "Rank-Up-Magic" card from your GY to your hand, but  you can only Special Summon one more time this turn.

function s.adfilter(c)
	return c:IsSetCard(SET_RANK_UP_MAGIC) and c:IsAbleToHand()
end

function s.adtar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.adfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,tp) return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)-e:GetLabel()>=1 end)
	e1:SetLabel(Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON))
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e2:SetValue(s.countval)
	Duel.RegisterEffect(e2,tp)
end

function s.countval(e,re,tp)
	local label=e:GetLabel()
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	if sp-label>=1 then
		return 0
	else
		return 1-sp+label
	end
end