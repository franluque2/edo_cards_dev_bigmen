--Burn Bribe
Duel.LoadScript("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
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
        e2:SetValue(s.refcon)
        Duel.RegisterEffect(e2,tp)

	end
	e:SetLabel(1)
end

function s.refcon(e,re,val,r,rp,rc)
    local cc=Duel.GetCurrentChain()
	if cc==0 or (r&REASON_EFFECT)==0 then return val end

	if  Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_DECK,0)>0 then 
        local g=Duel.GetDecktopGroup(e:GetHandlerPlayer(),1)

        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_ADJUST)
        e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
        e1:SetLabelObject(g:GetFirst())
        e1:SetOperation(s.millop)
        Duel.RegisterEffect(e1,e:GetHandlerPlayer())

        return 0
	else return val end
end


function s.millop(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabelObject()
	if val then
		e:SetLabelObject(nil)     
        Duel.SendtoHand(val, 1-tp, REASON_REPLACE+REASON_EFFECT)
        Duel.ConfirmCards(tp, val)
		e:Reset()
	end
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end