--Seeking the Light
Duel.LoadScript("big_aux.lua")
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

		--other passive duel effects go here    

    local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(s.coincon1)
	e3:SetOperation(s.coinop1)
    e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
    Duel.RegisterEffect(e3,tp)

    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
    Duel.RegisterEffect(e2,tp)


	end
	e:SetLabel(1)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsCode(23846921) and Duel.IsPhase(PHASE_END)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local e8=Effect.CreateEffect(e:GetHandler())
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetCode(EFFECT_CANNOT_TRIGGER)
    e8:SetTargetRange(LOCATION_MZONE,0)
    e8:SetCondition(s.discon)
    e8:SetTarget(s.actfilter)
    Duel.RegisterEffect(e8, tp)

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetValue(0)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    e2:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e2,tp)
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetReset(RESET_PHASE+PHASE_END,2)
    e3:SetTargetRange(0,1)
    Duel.RegisterEffect(e3,tp)
end

function s.discon(e)
	return Duel.IsPhase(PHASE_END)
end

function s.actfilter(e,c)
	return c:IsCode(23846921)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


    local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 12686296)
    for tc in g:Iter() do
        local effs={tc:GetOwnEffects()}
	for _,eff in ipairs(effs) do
		if eff:IsHasProperty(EFFECT_FLAG_PLAYER_TARGET) then
            eff:Reset()
        end
    end
    end
end


function s.coincon1(e,tp,eg,ep,ev,re,r,rp)
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_COIN)
    if rp~=tp then return false end
	if ex and ct>=1 then
		e:SetLabelObject(re)
		return true
	else return false end
end
function s.coinop1(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_COIN_NEGATE)
	e1:SetCondition(s.coincon2)
	e1:SetOperation(s.coinop2)
	e1:SetLabel(ev)
	e1:SetLabelObject(e:GetLabelObject())
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.coincon2(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject() and Duel.GetCurrentChain()==e:GetLabel()
end
function s.coinop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD, tp, id)
	local res={}
	for i=1,ev do
		table.insert(res,COIN_HEADS)
	end
	Duel.SetCoinResult(table.unpack(res))
end