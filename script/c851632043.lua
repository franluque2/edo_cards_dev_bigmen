--Phantom Beast Gale-Zephyr
local s,id=GetID()
function s.initial_effect(c)

	--spsumproc
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--summatk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	--summatk grant
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetTargetRange(LOCATION_MZONE+LOCATION_HAND,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1b))
	e4:SetLabelObject(e2)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetLabelObject(e3)
	c:RegisterEffect(e5)

end
s.listed_series={0x1b}

function s.hspcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),aux.TRUE,1,true,1,true,c,c:GetControler(),nil,false,e:GetHandler())
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,true,true,true,c,nil,nil,false,e:GetHandler())
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CanAttack() and Duel.IsExistingMatchingCard(Card.IsCanBeBattleTarget, tp, 0, LOCATION_MZONE, 1, nil,e:GetHandler()) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetHandler():CanAttack() and Duel.IsExistingMatchingCard(Card.IsCanBeBattleTarget, tp, 0, LOCATION_MZONE, 1, nil,e:GetHandler())) then return end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACKTARGET)
	local tc=Duel.SelectMatchingCard(tp, Card.IsCanBeBattleTarget, tp, 0, LOCATION_MZONE, 1,1, false,nil,e:GetHandler())
	if tc then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e3:SetOperation(s.damop)
		e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e3,tp)
		Duel.CalculateDamage(e:GetHandler(), tc:GetFirst())
	end
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
	Duel.ChangeBattleDamage(1-tp,0)
end
