--Call of the Shogun
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
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(s.spcon)
		e2:SetOperation(s.spop)
		Duel.RegisterEffect(e2,tp)

        local e3=e2:Clone()
        e3:SetCode(EVENT_SUMMON_SUCCESS)
        Duel.RegisterEffect(e3,tp)

        local e4=e2:Clone()
        e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
        Duel.RegisterEffect(e4,tp)




	end
	e:SetLabel(1)
end

local sixsams={}
sixsams[0]=Group.CreateGroup()
sixsams[1]=Group.CreateGroup()

local sixsamstoadd={
    44430454,83039729,6579928,95519486,49721904,27782503,70180284,75116619,31904181,15327215,44686185,74094021,78792195,48505422,90397998,64398890,69025477,65685470,61737116,2511717,7291576,1498130,71207871,101206020,101206019}

function s.generatesixsams(e,tp,eg,ep,ev,re,r,rp)
    if #sixsams[0]>0 then return end
    for i = 0, 1, 1 do
        for key,value in ipairs(sixsamstoadd) do
            local newcard=Duel.CreateToken(tp, value)
            Group.AddCard(sixsams[i], newcard)
        end
    end
end

function s.sixsamfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_SIX_SAMURAI) and not (c:GetFlagEffect(id)>0)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and eg:IsExists(s.sixsamfilter, 1, nil) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Group.IsExists(sixsams[tp], s.notonfieldfilter, 1, nil, tp)
end

function s.notonfieldfilter(c,tp)
    return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,  c:GetAttribute()), tp, LOCATION_MZONE, 0, 1, nil)
end

function s.getcard(tp)
    local g=Group.Filter(sixsams[tp], s.notonfieldfilter, nil, tp)
    local tc=Group.TakeatPos(g,Duel.GetRandomNumber(0, #g))
    return Card.GetOriginalCode(tc)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.Hint(HINT_CARD,tp,id)

    local cardid=s.getcard(tp)
    
    local tc=Duel.CreateToken(tp, cardid)
    tc:RegisterFlagEffect(id, RESETS_STANDARD-RESET_TOFIELD, 0,0)
    Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp,tp, true,true, POS_FACEUP)
    
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    s.generatesixsams(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
