--Capped Shackles of Ba
Duel.LoadScript("c420.lua")

Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)

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

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e8:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
        e8:SetTargetRange(0,1)
        e8:SetValue(1)
        Duel.RegisterEffect(e8,tp)


        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e11:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
        e11:SetTargetRange(0,1)
        e11:SetCondition(s.ndcon)
        e11:SetValue(1)
        Duel.RegisterEffect(e11,tp)


        
	end
	e:SetLabel(1)
end

function s.filter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard(0x40)
end

function s.ndcon(e)
    local g=Duel.GetMatchingGroup(s.filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return not (ct>4)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(Card.IsRace, tp, LOCATION_ALL, LOCATION_ALL, nil,RACE_ILLUSION)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do

			local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BATTLE_INDES)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(s.batval)
		tc:RegisterEffect(e1)

            tc=g:GetNext()
        end
    end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.batval(e,re,c)
	return re:GetHandler():IsRace(RACE_ILLUSION)
end

