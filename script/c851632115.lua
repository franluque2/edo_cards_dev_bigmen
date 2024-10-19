--Ringhorni the Shining Vassal
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
    e2:SetCost(s.negcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)


end

s.listed_series={0xbe}
function s.setfilter(c,e,tp)
	if not c:IsSetCard(0xbe) then return end
	if c:IsSpellTrap() then
		return (c:IsFieldSpell() or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and c:IsSSetable()
	end
	return false
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc:IsSpellTrap() then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,LOCATION_GRAVE)
	end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if tc:IsSpellTrap() then
		if tc:IsFieldSpell() then
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
		end
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.SSet(tp,tc)
            Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)

		end
	end
end



function s.negcostfilter(c)
	return c:HasLevel() and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and
		Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g+c,POS_FACEUP,REASON_COST)
    local lvl=Group.GetSum(g+c, Card.GetOriginalLevel, nil)
    e:SetLabel(lvl)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsFaceup() and c:IsNegatable()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_SZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spfilter(c,e,tp,lvl)
    return c:IsType(TYPE_SYNCHRO) and c:IsLevel(lvl) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false,false)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local lvl=e:GetLabel()
    local g=Duel.GetMatchingGroup(s.thfilter, tp, LOCATION_ONFIELD, 0, nil)
    for tc in g:Iter() do
		tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
	end
    Duel.BreakEffect()
    local g2=Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_EXTRA, 0,nil,e,tp,lvl)
    if #g2>0 and Duel.GetLocationCountFromEx(tp, tp)>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
        local tosum=g2:Select(tp, 1,1,nil)
        if tosum then
            if Duel.SpecialSummon(tosum, SUMMON_TYPE_SYNCHRO, tp, tp,false,false, POS_FACEUP) then
                tosum:GetFirst():CompleteProcedure()
            end
        end
    end
end
