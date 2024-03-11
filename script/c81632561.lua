--Kabuki Stage - Cherry Blossom Mountain (CT)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

    --Activate 1 "Kabuki Stage" Field Spell from hand or deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(s.accost)
	e2:SetTarget(s.tftg)
	e2:SetOperation(s.tfop)
	c:RegisterEffect(e2)

    --Gain LP
	local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetRange(LOCATION_FZONE)
    e3:SetTarget(s.battg)
	e3:SetCondition(s.accon)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)

    --Change Position (QE)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
    local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)

end

function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.filter(c,tp)
	return c:IsCode(511000716, 511000718, 511000715)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	if not Duel.CheckPhaseActivity() then Duel.RegisterFlagEffect(tp,CARD_MAGICAL_MIDBREAKER,RESET_CHAIN,0,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	aux.ToHandOrElse(tc,tp,function(c)
								local te=tc:GetActivateEffect()
								return te:IsActivatable(tp,true,true)
							end,
							function(c)
								Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
							end,
							aux.Stringid(id,2))
end

function s.cfilter(c)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return not c:IsStatus(STATUS_CONTINUOUS_POS) and ((np<3 and pp>3) or (pp<3 and np>3))
    
end
function s.battg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(200)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,200)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Recover(p,d,REASON_EFFECT)
end

function s.filter2(c)
	return c:IsType(TYPE_MONSTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter2,1,nil,tp) and #eg==1
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetLabelObject(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
