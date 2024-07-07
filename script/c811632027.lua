--The Twilit Twins
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

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_REMOVE)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2,tp)   

	end
	e:SetLabel(1)
end


function s.adbackfilter(c)
    return c:GetFlagEffect(id)>0 and c:IsAbleToHand()
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.adbackfilter, tp, LOCATION_REMOVED, 0, 1, nil)
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(s.adbackfilter, tp, LOCATION_REMOVED, 0, nil)
    if g then
        Duel.SendtoHand(g, tp, REASON_RULE)
    end
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local pdragon=Duel.CreateToken(tp, 19959563)
        local e1=Effect.CreateEffect(pdragon)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
        e1:SetCode(EFFECT_SPSUMMON_PROC)
        e1:SetRange(LOCATION_HAND)
        e1:SetCondition(s.spcon)
        pdragon:RegisterEffect(e1)
    pdragon:RegisterFlagEffect(id, 0,0,0)
    Duel.SendtoGrave(pdragon, REASON_RULE)
    local jdragon=Duel.CreateToken(tp, 57774843)
    local e2=Effect.CreateEffect(jdragon)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon2)
	jdragon:RegisterEffect(e2)
    jdragon:RegisterFlagEffect(id, 0,0,0)
    Duel.SendtoGrave(jdragon, REASON_RULE)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.spfilter2(c)
	return c:IsRace(RACE_DRAGON)
end
function s.spcon2(e,c)
	if c==nil then return true end
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.spfilter2,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>3
end


function s.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsMonster()
end
function s.spcon(e,c)
	if c==nil then return true end
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.spfilter,c:GetControler(),LOCATION_REMOVED,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>3
end