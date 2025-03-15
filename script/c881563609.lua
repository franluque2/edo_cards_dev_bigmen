--Stealer of Souls
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(function(e) return Duel.GetLP(e:GetHandlerPlayer())<Duel.GetLP(1-e:GetHandlerPlayer()) end)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
    e2:SetCountLimit(3,id)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e3)

    local e4=e2:Clone()
    e4:SetCode(EVENT_CHAINING)
    c:RegisterEffect(e4)

    aux.GlobalCheck(s,function()
		--register
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DRAW)
		ge1:SetOperation(s.op)
		Duel.RegisterEffect(ge1,0)
	end)

end

function s.drawnthisturnfilter(c)
    return c:HasFlagEffect(id)
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    if not eg and not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
    if re and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
        if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
        eg=Group.CreateGroup()
        eg:AddCard(re:GetHandler())
    end
	local tg=eg:Filter(s.drawnthisturnfilter, nil)
	return #tg>0 and not tg:IsContains(e:GetHandler()) and Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)

	Duel.Draw(p,d,REASON_EFFECT)
    Duel.BreakEffect()
    Duel.Damage(p, 1000, REASON_EFFECT)
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=eg
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END-RESET_TOFIELD,0,1)
		tc=g:GetNext()
	end
end
