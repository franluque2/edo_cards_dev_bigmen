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
	e4:SetCode(EVENT_BATTLED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(s.battlecon)
	e4:SetOperation(s.battleop)
	c:RegisterEffect(e4)

end
s.listed_names={TOKEN_FOLLOWUP}


function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
	return WbAux.CanPlayerSpecialSummonFollowupToken(tp)
end

function s.battleop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local token=WbAux.GetFollowupToken(tp,e:GetHandler())
    if token then
        local g=Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
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