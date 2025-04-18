--Graydle Overmind
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCountLimit(1,{id,1})
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)

    local e4=e2:Clone()
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)


    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.controlfilter)
	e3:SetValue(1)
	c:RegisterEffect(e3)

    local e5=e3:Clone()
    e5:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(e5)

end
s.listed_series={0xd1}

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_SZONE,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        local ac=Duel.GetAttacker()
		if ac:CanAttack() and not ac:IsImmuneToEffect(e) then
			Duel.CalculateDamage(ac,tc)
		end

	end
end


function s.thfilter(c)
	return c:IsSetCard{0xd1} and c:IsFaceup() and c:IsMonsterCard()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.thfilter(chkc) and not chkc==e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local sc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
			if sc then
				Duel.HintSelection(sc)
				Duel.GetControl(sc,tp)
			end
	end
end

function s.controlfilter(e,c)
    return c:GetControler()~=c:GetOwner()
end

function s.ownerfilter(c,tp)
    return not c:IsOwner(tp)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(s.ownerfilter,1,nil,tp)
end



function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (re and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) or e==re then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	return g:GetFirst():IsLocation(LOCATION_ONFIELD)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xd1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevelBelow(5)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_SZONE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_SZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_SZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_SZONE,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
