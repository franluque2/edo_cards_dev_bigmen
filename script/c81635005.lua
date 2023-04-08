--Wombat Turbo
Duel.LoadScript("big_aux.lua")


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


	end
	e:SetLabel(1)
end


function s.notchumleyfilter(c)
	return c:IsAustralian() and not c:IsCode(81635012)
end

function s.aussiefilter(e,c)
	return c:IsFaceup() and c:IsAustralian()
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.flipcon2)
	e1:SetOperation(s.flipop2)
	Duel.RegisterEffect(e1,tp)

	--Increase ATK
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.aussiefilter)
	e4:SetValue(500)
	Duel.RegisterEffect(e4,tp)

	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e5,tp)



	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_ADJUST)
	e3:SetCountLimit(1)
	e3:SetCondition(s.flipcon3)
	e3:SetOperation(s.flipop3)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1)
	e4:SetCondition(s.flipcon4)
	e4:SetOperation(s.flipop4)
	Duel.RegisterEffect(e4,tp)

	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_NEGATED)
	Duel.RegisterEffect(e5,tp)

	local e6=e4:Clone()
	e6:SetCode(EVENT_SUMMON_NEGATED)
	Duel.RegisterEffect(e6,tp)

	local e7=e4:Clone()
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	Duel.RegisterEffect(e7,tp)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.notchumleyfilter,1,nil) and Duel.GetFlagEffect(tp, id+1)==0
end

function s.wasnotmaterialfilter(c)
	return (c:GetReason()==(REASON_RELEASE) or c:IsReason(REASON_SUMMON)
	or c:IsReason(REASON_FUSION|REASON_SYNCHRO|REASON_LINK))
end

function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.wasnotmaterialfilter, 1, nil) then
		Duel.RegisterFlagEffect(tp, id+2, RESET_EVENT+RESET_PHASE+PHASE_END, 0, 0)
	else
		Duel.RegisterFlagEffect(tp, id+1, RESET_EVENT+RESET_PHASE+PHASE_END, 0, 0)
	end
end

function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+1)==1 and Duel.GetCurrentChain()==0 and Duel.GetFlagEffect(tp, id+4)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_CARD,tp,id)

	local token=Duel.CreateToken(tp, 81635012)
	Duel.SpecialSummon(token, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
	Duel.RegisterFlagEffect(tp, id+4, RESET_PHASE+PHASE_END, 0, 0)
end



function s.flipcon4(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+2)==1 and Duel.GetCurrentChain()==0 and Duel.GetFlagEffect(tp, id+4)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0
end
function s.flipop4(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp, id+4)==0 then
	Duel.Hint(HINT_CARD,tp,id)

	local token=Duel.CreateToken(tp, 81635012)
	Duel.SpecialSummon(token, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
	Duel.RegisterFlagEffect(tp, id+4, RESET_PHASE+PHASE_END, 0, 0)
	end
end
