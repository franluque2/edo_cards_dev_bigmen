--Into the Supreme Darkness
--Duel.LoadScript("big_aux.lua")

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
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here   
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_SUPREME_CASTLE)
		e2:SetTargetRange(1,0)
		Duel.RegisterEffect(e2,tp)

	
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_SOLVED)
		e3:SetCondition(s.negcon)
		e3:SetOperation(s.negop)
		Duel.RegisterEffect(e3,tp)

		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_SPSUMMON_SUCCESS)
		e5:SetCondition(s.thcond)
		e5:SetOperation(s.limop)
        Duel.RegisterEffect(e5, tp)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_CHAIN_END)
		e4:SetOperation(s.limop2)
        Duel.RegisterEffect(e4, tp)


		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e6:SetTargetRange(LOCATION_MZONE,0)
		e6:SetTarget(s.efilter)
		e6:SetValue(1)
        Duel.RegisterEffect(e6, tp)

		local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetTargetRange(0,LOCATION_MZONE)
		e7:SetCondition(s.confunc)
        e7:SetValue(s.teefilter)
        Duel.RegisterEffect(e7, tp)
	
	end
	e:SetLabel(1)
end

function s.efilter(e,c)
	return c:IsCode(86165817)
end

function s.confunc(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and Duel.IsBattlePhase()
end

function s.teefilter(e,te)
	return e:GetOwnerPlayer()==te:GetOwnerPlayer() and te:GetHandler():IsCode(86282581)
end

function s.cfilter2(c,tp)
	return c:IsCode(13708888) and c:IsControler(tp)
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.cfilter2,1,nil,tp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id+1)
	e:Reset()
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id+1)>0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id+1)
end

function s.chainlm(e,rp,tp)
	return (tp~=rp) or (not e:GetHandler():IsCode(13708888))
end


function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsCode(CARD_SUPER_POLYMERIZATION)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	Duel.Hint(HINT_CARD, tp, id)
	Card.CancelToGrave(tc)
	Duel.SendtoDeck(tc, tp, SEQ_DECKSHUFFLE, REASON_RULE)
end

function s.fusionfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_EVIL_HERO) and not c:IsAttribute(ATTRIBUTE_DARK)
end

function s.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end

function s.oppmonster(c,fc,sumtype,tp)
    return c:GetControler()~=tp and not Duel.IsExistingMatchingCard(s.atkfilter, tp, 0, LOCATION_MZONE, 1, c, c:GetAttack())
end

function s.ctfusmat(c,fc,sumtype,tp)
    return c:IsSetCard(SET_EVIL_HERO,fc,sumtype,tp) and c:IsCanBeFusionMaterial(e,tp)
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	local g=Duel.GetMatchingGroup(s.fusionfilter, tp, LOCATION_EXTRA, 0, nil)
    for tc in g:Iter() do
        Fusion.AddProcMix(tc,true,true,s.oppmonster,s.ctfusmat)
    end

	local neos=Duel.GetMatchingGroup(Card.IsOriginalCode,tp,LOCATION_EXTRA,0,nil,13708888)
	for tc in neos:Iter() do
		local effs={tc:GetOwnEffects()}
		for _,eff in ipairs(effs) do
			if eff:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE then
				eff:SetValue(0)
			end
		end
	end

	local malibane=Duel.GetMatchingGroup(Card.IsOriginalCode,tp,LOCATION_EXTRA,0,nil,86165817)
	for tc in malibane:Iter() do
		local effs={tc:GetOwnEffects()}
		for _,eff in ipairs(effs) do
			if eff:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE or eff:GetCode()==EFFECT_INDESTRUCTABLE_EFFECT then
				eff:SetValue(0)
			end
		end
	end
end