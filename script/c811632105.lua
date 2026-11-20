--The One Card Wonder
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

        local e0=Effect.CreateEffect(e:GetHandler())
        e0:SetType(EFFECT_TYPE_FIELD)
        e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e0:SetCode(EFFECT_CANNOT_ACTIVATE)
        e0:SetTargetRange(1,0)
        e0:SetValue(function(e,re) return not re:GetHandler():IsCode(id) end)
        e0:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e0,tp)




        local c=e:GetHandler()

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
        e1:SetCountLimit(1)
		e1:SetOperation(s.flipop)
        e1:SetLabelObject(e0)
		Duel.RegisterEffect(e1,tp)

        local e5=Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e5:SetTargetRange(1,0)
        e5:SetCode(EFFECT_SKIP_DP)
		Duel.RegisterEffect(e5,tp)


        local e6=Effect.CreateEffect(c)
        e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e6:SetCode(EVENT_ADJUST)
        e6:SetCondition(s.drawcon)
        e6:SetOperation(s.drawop)
        Duel.RegisterEffect(e6,tp)
    end
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id, 0))
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND,0,nil)
    if #g>0 then
        local sg=g:Select(tp,1,1,nil)
        g:RemoveCard(sg:GetFirst())
    end
    Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_RULE)

    e:GetLabelObject():Reset()
end


function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_HAND,0) == 0
end

function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_RULE)
end
