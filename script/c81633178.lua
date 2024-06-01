--March of the Shadow Riders
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

    aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)

end



function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

	end
	e:SetLabel(1)
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end

function s.spsumfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.discardmonfilter(c)
    return c:IsMonster() and c:IsDiscardable(REASON_COST)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

    local g=Duel.GetMatchingGroup(s.discardmonfilter, tp, LOCATION_HAND, 0, nil)

	return aux.CanActivateSkill(tp) and g:CheckWithSumGreater(Card.GetLevel,10) and Duel.IsExistingMatchingCard(s.spsumfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
	Duel.Hint(HINT_CARD,tp,id)
    local g=Duel.GetMatchingGroup(s.discardmonfilter, tp, LOCATION_HAND, 0, nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sg=g:SelectWithSumGreater(tp,Card.GetLevel,10)
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)

    local tg=Duel.SelectMatchingCard(tp, s.spsumfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
    if tg then
        Duel.SpecialSummon(tg, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
    end



	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    end
end
