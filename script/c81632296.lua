--Rank Gazer (CT)
Duel.LoadScript("c420.lua")

local s,id=GetID()
function s.initial_effect(c)
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

    --become an astral card
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_ADD_SETCODE)
    e3:SetValue(0x505)
    e3:SetRange(LOCATION_ALL)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
    c:RegisterEffect(e3)
end

function s.numberfilter(c)
    return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.fuXyzFilter(c)
    return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.fuXyzFilter,tp,LOCATION_MZONE,0,nil)
	local sum=g:GetSum(Card.GetRank)*100
	if chk==0 then return sum>0 and Duel.IsExistingTarget(s.numberfilter, tp, LOCATION_MZONE, 0, 1,nil) end
	Duel.SetTargetPlayer(tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.numberfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,sum)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(s.fuXyzFilter,tp,LOCATION_MZONE,0,nil)
	local sum=g:GetSum(Card.GetRank)*100
	Duel.Recover(p,sum,REASON_EFFECT)

    local tc=Duel.GetFirstTarget()
    local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
        e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_LEAVE_FIELD)
        e2:SetCondition(s.spcon)
        e2:SetOperation(s.spop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetLabelObject(tc)
		Duel.RegisterEffect(e2,tp)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+RESET_PHASE+PHASE_END,0,1)

end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local atk=e:GetLabelObject():GetBaseAttack()
	if atk<0 then atk=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:IsContains(tc) and tc:GetFlagEffect(id)~=0
		and tc:IsReason(REASON_DESTROY)
end

function s.cfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsPreviousControler(tp) and c:IsControler(tp) and c:GetFlagEffect(id)~=0
end

function s.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsSetCard(0x48) and not c:IsSetCard(0x107f)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_CARD,0,id)
		local at=eg:Filter(s.cfilter,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		Duel.Overlay(sg:GetFirst(),at,true)
	end
end
