--Scab Conscription
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
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_CODE)
        e5:SetTargetRange(LOCATION_MZONE,0)
        e5:SetValue(100000224)
        Duel.RegisterEffect(e5,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_CONTROL_CHANGED)
        e3:SetCondition(s.chcon)
        e3:SetOperation(s.chop)
        Duel.RegisterEffect(e3,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_SPSUMMON_SUCCESS)
		e8:SetOperation(s.reborncheck)
		Duel.RegisterEffect(e8,tp)
	end
	e:SetLabel(1)
end

function s.reborncheck(e,tp,eg,ev,ep,re,r,rp)
	if (not re) or (rp~=tp) then return end
    local g=eg:Filter(s.changconfilter, nil, tp)
    if #g>0 then
        Duel.Hint(HINT_CARD,tp,id)
    end
	local ec=g:GetFirst()
	while ec do
        if ec:GetPreviousLocation()==LOCATION_GRAVE then
            ec:AddCounter(0x109a,1)
        end
		ec=g:GetNext()
	end
end

function s.changconfilter(c,tp)
    return c:GetOwner()~=tp
end

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.changconfilter, 1, nil, tp)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.changconfilter, nil, tp)
    if #g>0 then
        Duel.Hint(HINT_CARD,tp,id)
    end
    for tc in g:Iter() do
        tc:AddCounter(0x109a,1)
    end
end



function s.markedfilter(c,e)
    return #c:IsHasEffect(e)>0
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
