--Creative Accounting
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
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    

		local ge=Effect.CreateEffect(e:GetHandler())
		ge:SetType(EFFECT_TYPE_FIELD)
		ge:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		ge:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge:SetTargetRange(LOCATION_SZONE,0)
		ge:SetTarget(function(e,cc) return cc:IsType(TYPE_SPELL) and cc:IsOriginalCode(id+1) end)
		ge:SetOperation(s.AuxHandling)
		ge:SetValue(aux.TRUE())
		Duel.RegisterEffect(ge,tp)
            
            end
	e:SetLabel(1)
end

function s.AuxHandling(e,tc,tp,sg)
    sg:RemoveCard(e:GetHandler())
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


    local chain=Duel.CreateToken(tp, id+1)
    Duel.MoveToField(chain,tp,tp,LOCATION_SZONE,POS_FACEUP,true)

end