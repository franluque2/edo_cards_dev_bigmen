--Astaviah, the Umbral Urge
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Synchro summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_FIEND),1,99)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.countcon)
	e1:SetOperation(s.countop)
	c:RegisterEffect(e1)

    	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	

end

function s.countcon(e,tp,eg,ep,ev,re,r,rp)
	return ev>2
end
function s.countop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 0)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0 and Duel.IsChainDisablable(ev) and ev<=2
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD, tp, id)
	Duel.NegateEffect(ev)
end