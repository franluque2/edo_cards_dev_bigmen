--Intelligencia Guild Savant - Dr. Ratio
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,nil,s.matcheck)

	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--the ATK/DEF of all tokens you control becomes double their original ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE, 0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOKEN))
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e3:SetValue(s.defval)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(s.battlecon)
	e4:SetOperation(s.battleop)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)

	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_ADJUST)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(function(e) return (e:GetHandler():GetFlagEffect(id)>0) and (Duel.GetCurrentChain()==0) and (not Duel.IsPhase(PHASE_DAMAGE)) end)
	e7:SetOperation(s.adop)
	c:RegisterEffect(e7)

	local e6=e4:Clone()
	e6:SetCode(EVENT_CUSTOM+id)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(s.battlecon2)
	c:RegisterEffect(e6)

end
s.listed_names={TOKEN_FOLLOWUP}

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	Duel.RaiseSingleEvent(e:GetHandler(), EVENT_CUSTOM+id, 0, REASON_EFFECT, e:GetHandlerPlayer(), e:GetHandlerPlayer(), 0)
end

function s.battlecon2(e,tp,eg,ep,ev,re,r,rp)
	return WbAux.CanPlayerSpecialSummonFollowupToken(tp)
end


function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		Duel.CalculateDamage(e:GetHandler(), tc)
	end
end

function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
	return WbAux.CanPlayerSpecialSummonFollowupToken(tp) and (e:GetHandler():GetFlagEffect(id)==0)
end

function s.notbattledestroyed(c)
	return not (c:IsStatus(STATUS_DESTROY_CONFIRMED) or c:IsStatus(STATUS_BATTLE_DESTROYED))
end

function s.battleop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local token=WbAux.GetFollowupToken(tp,e:GetHandler())
    if token then
        local g=Duel.GetMatchingGroup(s.notbattledestroyed, tp, 0, LOCATION_MZONE, nil)
        if g and (#g>0) then
            local tc=g:RandomSelect(tp, 1):GetFirst()
            Duel.CalculateDamage(token, tc)
        else
            Duel.CalculateDamage(token, nil)
        end
    end
    if Card.IsOnField(token) then
        Duel.Destroy(token, REASON_RULE)
    end
    e:GetHandler():RemoveCounter(tp,COUNTER_DEBTOR,3,REASON_EFFECT)
end


function s.matcheck(g,lnkc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_IPC,lnkc,sumtype,tp)
end

function s.atkval(e,c)
	return c:GetBaseAttack()*2
end

function s.defval(e,c)
	return c:GetBaseDefense()*2
end