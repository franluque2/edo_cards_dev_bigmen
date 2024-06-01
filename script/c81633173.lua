--Eternal Love
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



function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil)
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
	Duel.Hint(HINT_CARD,tp,id)

    local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHAIN_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.chtg)
	e4:SetOperation(s.chop)
    e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetValue(1)
    e4:SetCountLimit(1)
    e4:SetValue(aux.TRUE)
    Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetOperation(s.chk)
	e4:SetLabelObject(e5)

    local e12=Effect.CreateEffect(e:GetHandler())
    e12:SetType(EFFECT_TYPE_FIELD)
    e12:SetCode(EFFECT_FUSION_SUBSTITUTE)
    e12:SetTargetRange(0,LOCATION_MZONE)
    e12:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e12,tp)

	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    end
end


function s.chfilter(c,e,tp)
	return c:IsMonster() and (c:IsFaceup() or c:IsControler(tp)) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.chtg(e,te,tp,value)
	if value&SUMMON_TYPE_FUSION==0 then return Group.CreateGroup() end
	return Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,te,tp)
end
function s.chop(e,te,tp,tc,mat,sumtype,sg,sumpos)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	if sg then
		sg:AddCard(tc)
	else
		Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,sumpos)
	end
end
function s.chk(tp,sg,fc)
	return sg:FilterCount(Card.IsControler,nil,1-tp)<=1
end
