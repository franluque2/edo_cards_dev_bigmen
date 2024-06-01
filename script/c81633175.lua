--Numbers Club! Don't Give Up!
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

function s.secondmonfilter(c,e,tp, firstcar)
    if not (c:HasLevel() and c:IsLevel(firstcar:GetLevel()) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)) then return false end
    local g=Group.CreateGroup()
    g:AddCard(c)
    g:AddCard(firstcar)
    return Duel.IsExistingMatchingCard(s.xyzchk,tp,LOCATION_EXTRA,0,1,nil,g,2,2,tp)
end

function s.firstmonfilter(c,e,tp)
    return c:HasLevel() and Duel.IsExistingMatchingCard(s.secondmonfilter, c:GetControler(), LOCATION_GRAVE, 0, 1, c, e,tp,c)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

	return aux.CanActivateSkill(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and Duel.IsExistingMatchingCard(s.firstmonfilter, tp, LOCATION_MZONE, 0, 1, nil,e,tp)
end


function s.xyzchk(c,sg,minc,maxc,tp)
	return c:IsXyzSummonable(nil,sg,minc,maxc) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end


function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
	Duel.Hint(HINT_CARD,tp,id)

    local firsttar=Duel.SelectMatchingCard(tp, s.firstmonfilter, tp, LOCATION_MZONE, 0, 1,1,false, nil,e,tp)
    if firsttar then
        Duel.HintSelection(firsttar)
        local tc1=firsttar:GetFirst()
        local secondtar=Duel.SelectMatchingCard(tp, s.secondmonfilter, tp, LOCATION_GRAVE, 0, 1,1,false, firsttar, e,tp,tc1)
        if secondtar then
            Duel.SpecialSummon(secondtar, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
        end

        local sg=Group.CreateGroup()
        sg:AddCard(tc1)
        sg:AddCard(secondtar)


        Duel.BreakEffect()
        local xyzg=Duel.GetMatchingGroup(s.xyzchk,tp,LOCATION_EXTRA,0,nil,sg,2,2,tp)
        if #xyzg>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
            Duel.XyzSummon(tp,xyz,sg,sg)
        end
    
    end


	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    end
end