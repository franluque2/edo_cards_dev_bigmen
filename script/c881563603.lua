--Blightborn Tamsin
local s,id=GetID()
function s.initial_effect(c)

    --search
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.thcon)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCode(id)
    e3:SetTargetRange(1,0)
    Duel.RegisterEffect(e3,tp)

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_REFLECT_DAMAGE)
    e1:SetTargetRange(1,0)
    e1:SetCondition(function (e) return Duel.IsTurnPlayer(e:GetHandlerPlayer()) end)
    e1:SetValue(1)
    Duel.RegisterEffect(e1,tp)

    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_LPCOST_REPLACE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
    Duel.RegisterEffect(e2,tp)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsTurnPlayer(tp) then return false end
	if re and tp==ep and Duel.GetFlagEffect(tp,id)==0 then
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT,0,0)
		local res=Duel.CheckLPCost(1-ep,ev)
        Duel.ResetFlagEffect(tp,id)
        return res
	end
	return false
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_EVENT,0,0)
	Duel.Hint(HINT_CARD,0,e:GetHandler():GetOriginalCode())
	Duel.PayLPCost(1-ep,ev)
    Duel.ResetFlagEffect(tp,id)
    end

function s.val(e)
    return true
end