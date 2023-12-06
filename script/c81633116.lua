--Chosen by the Dark Duel Dragon

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
        e5:SetTargetRange(LOCATION_ALL,0)
        e5:SetTarget(function(_,c)  return c:IsOriginalCode(60992105,100000282) end)
        e5:SetValue(CARD_BLACK_WINGED_DRAGON)
        Duel.RegisterEffect(e5,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
    Duel.RegisterEffect(e2,tp)
    

	end
	e:SetLabel(1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local card=re:GetHandler()
	return card and re:IsActiveType(TYPE_MONSTER)
		and card:IsCode(60992105,100000282)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local card=re:GetHandler()

    card:AddCounter(0x10,1)


end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local darkdragons=Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ALL, LOCATION_ALL, nil, 60992105,100000282)
    for dragon in darkdragons:Iter() do
        dragon:EnableCounterPermit(0x10)
    end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
