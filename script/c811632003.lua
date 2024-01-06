--Desire for Greed
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
		Duel.RegisterEffect(e1,tp)

        local c=e:GetHandler()

        local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.actarget)
	e2:SetCost(s.costchk)
	e2:SetOperation(s.costop)
    Duel.RegisterEffect(e2,tp)
	--summon cost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SUMMON_COST)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCost(s.costchk)
	e3:SetOperation(s.costop)
    Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SPSUMMON_COST)
    Duel.RegisterEffect(e4,tp)
	--set cost
	local e5=e3:Clone()
	e5:SetCode(EFFECT_MSET_COST)
    Duel.RegisterEffect(e5,tp)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_SSET_COST)
    Duel.RegisterEffect(e6,tp)


	end
	e:SetLabel(1)
end

function s.actarget(e,te,tp)
	return te:GetHandler():IsLocation(LOCATION_HAND)
end
function s.costchk(e,te_or_c,tp)
    local  g=Duel.GetDecktopGroup(tp,5)
	return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==5 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=7 and Duel.IsPlayerCanDraw(tp)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
    local  g=Duel.GetDecktopGroup(tp,5)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
    Duel.Draw(tp, 2, REASON_COST)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
