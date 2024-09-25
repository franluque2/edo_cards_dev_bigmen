--Decalnotaurus Shield
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.poscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
function s.posconfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(1-tp)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.posconfilter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsRace(RACE_DINOSAUR) and c:IsCanChangePositionRush()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,2,nil)
	if #g2>0 then
		Duel.HintSelection(g2)
		for tc in g2:Iter() do
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
			local ge0=Effect.CreateEffect(e:GetHandler())
            ge0:SetCode(EFFECT_UPDATE_ATTACK)
            ge0:SetType(EFFECT_TYPE_SINGLE)
            ge0:SetValue(300)
            ge0:SetReset(RESET_PHASE+PHASE_END)
            local ge1=Effect.CreateEffect(e:GetHandler())
            ge1:SetCode(EFFECT_UPDATE_DEFENSE)
            ge1:SetType(EFFECT_TYPE_SINGLE)
            ge1:SetValue(300)
            ge1:SetReset(RESET_PHASE+PHASE_END)
	end
end

