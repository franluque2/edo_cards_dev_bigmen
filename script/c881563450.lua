--The Dragon Balls
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(DRAGON_BALL_COUNTER)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)


    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.atktg)
	e4:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e4)


    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCost(s.cost2)
	e5:SetTarget(s.tg2)
	e5:SetOperation(s.op2)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_CONJURE)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCost(s.cost3)
	e6:SetOperation(s.op3)
	c:RegisterEffect(e6)
end
s.listed_names={id+1}
s.listed_series={SET_DRAGON_BALL}
s.counter_place_list={DRAGON_BALL_COUNTER}

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Card.IsCanRemoveCounter(e:GetHandler(), tp, DRAGON_BALL_COUNTER, 1, REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    e:GetHandler():RemoveCounter(tp, DRAGON_BALL_COUNTER, 1, REASON_COST)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetFlagEffect(id, 0)==0 end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(s.actop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1))
    Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 0)
end

function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Card.IsCanRemoveCounter(e:GetHandler(), tp, DRAGON_BALL_COUNTER, 7, REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    e:GetHandler():RemoveCounter(tp, DRAGON_BALL_COUNTER, 7, REASON_COST)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
    local Shenon=Duel.CreateToken(tp, 881563451)
    Duel.SendtoHand(Shenon, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, Shenon)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsSetCard(SET_DRAGON_BALL) and ep==tp then
		Duel.SetChainLimit(function(e,rp,tp) return tp==rp end)
	end
end


function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:GetReasonCard():IsSetCard(SET_DRAGON_BALL)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(DRAGON_BALL_COUNTER)<7 end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():AddCounter(DRAGON_BALL_COUNTER,1)
end


function s.atktg(e,c)
	return c:IsSetCard(SET_DRAGON_BALL)
end