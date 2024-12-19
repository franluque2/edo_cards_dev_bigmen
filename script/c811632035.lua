--Advent of Kuribohs
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

            
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CHANGE_DAMAGE)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetTargetRange(1,0)
        e2:SetValue(s.val1)
        Duel.RegisterEffect(e2,tp)
    


        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e5:SetCode(EVENT_BATTLE_DAMAGE)
        e5:SetOperation(s.regop)
        Duel.RegisterEffect(e5,tp)
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e6:SetCode(EVENT_DAMAGE_STEP_END)
        e6:SetCondition(s.poscon)
        e6:SetOperation(s.posop)
        e6:SetLabelObject(e5)
        Duel.RegisterEffect(e6,tp)



        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetCode(EVENT_PHASE+PHASE_END)
        e4:SetCondition(s.flipcon2)
        e4:SetOperation(s.flipop2)
        e4:SetCountLimit(1)
        Duel.RegisterEffect(e4,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e8:SetCode(EVENT_PREDRAW)
        e8:SetCondition(s.flipcon3)
        e8:SetOperation(s.flipop3)
        e8:SetCountLimit(1)
        Duel.RegisterEffect(e8,tp)
    end
	e:SetLabel(1)
end

function s.val1(e,re,dam,r,rp,rc)
	if (r&(REASON_BATTLE+REASON_EFFECT)~=0) and (Duel.GetLP(e:GetHandlerPlayer())-dam<=0) then
        Duel.SetLP(e:GetHandlerPlayer(), 8000)
		return 0
	else return dam end
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)==0
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnCount()<24 then
        if Duel.GetTurnPlayer()==tp then
            Duel.Hint(HINT_CARD, tp, id)
        end
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0,0)
    end
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id)>0
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

    local toskipnum=Duel.GetFlagEffect(tp, id)

    if (toskipnum*2+1)+Duel.GetTurnCount()>24 then
        toskipnum=math.floor((25-Duel.GetTurnCount())/2+0.5)-1
    end
    if toskipnum<0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_SKIP_TURN)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,toskipnum+1)
    Duel.RegisterEffect(e1,tp)


    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_SKIP_TURN)
    e2:SetTargetRange(0,1)
    e2:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,toskipnum)
    Duel.RegisterEffect(e2,tp)
end

function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==25
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
    Duel.Win(Duel.GetTurnPlayer(), 0x2682)

end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

end