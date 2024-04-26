--Meteor Shower
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)


end



function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)
    

		--other passive duel effects go here    

		aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(e:GetHandler())
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetCondition(s.checkcon)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
        local ge2=ge1:Clone()
        ge2:SetCode(EVENT_SUMMON_SUCCESS)
        Duel.RegisterEffect(ge2,0)
		end)

	end
	e:SetLabel(1)
end

function s.notmarked(c)
	return not (c:GetFlagEffect(id)>0)
end

function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(0, id-500)==0
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(0, id-500)>0 then return end
	Duel.RegisterFlagEffect(0, id-500, RESET_PHASE|PHASE_END, 0, 1)
	eg=eg:Filter(s.notmarked, nil)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	end


    if Duel.GetFlagEffect(0, id)>=5 then
		Duel.Hint(HINT_CARD, ep, 27204311)

	local sump=1-Duel.GetTurnPlayer()
    
    local c=Duel.CreateToken(sump, 27204311)
	if c:IsCanBeSpecialSummoned(e,0,sump,false,false) then 
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsReleasableByEffect),sump,LOCATION_MZONE,LOCATION_MZONE,nil)
		if Duel.Release(g,REASON_EFFECT)==0 then return end
		local og=Duel.GetOperatedGroup()
		c:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD, 0, 0)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummon(c,0,sump,sump,false,false,POS_FACEUP_ATTACK)>0
			and Duel.GetMZoneCount(1-sump,nil,sump)>0 then
			local atk=og:GetSum(s.operationvalueatk)
			local def=og:GetSum(s.operationvaluedef)
			if not Duel.IsPlayerCanSpecialSummonMonster(1-sump,27204311+1,0,TYPES_TOKEN,atk,def,11,RACE_ROCK,ATTRIBUTE_LIGHT,POS_FACEUP_ATTACK,1-sump) then return end
			Duel.BreakEffect()
			local token=Duel.CreateToken(sump,27204311+1)
			Duel.SpecialSummonStep(token,0,sump,1-sump,false,false,POS_FACEUP_ATTACK)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE)
			e2:SetValue(def)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e2)
			Duel.SpecialSummonComplete()
			token:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD, 0, 0)

		end
		end

		Duel.ResetFlagEffect(0, id)
    end
	Duel.ResetFlagEffect(0, id-500)

end

function s.operationvalueatk(c)
	return math.max(c:GetBaseAttack(),0)
end
function s.operationvaluedef(c)
	return math.max(c:GetBaseDefense(),0)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end


