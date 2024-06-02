--Action Field - Crossover
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
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
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)



        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetCategory(CATEGORY_ATKCHANGE)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_ATTACK_ANNOUNCE)
        e2:SetCondition(s.condition)
        e2:SetOperation(s.activate)
		Duel.RegisterEffect(e2,tp)

	end
	e:SetLabel(1)
end

function s.spsumfilter(c,e,tp)

    return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetFlagEffect(tp, id)==1
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
    Duel.Hint(HINT_CARD,tp,id)

    local d=Duel.TossDice(tp,1)
	if d==1 or d==3 or d==5 then

	elseif d==2 then
		Duel.NegateAttack()
	elseif d==4 then

	local bc=Duel.GetAttacker()
	if bc:IsRelateToBattle() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
			bc:RegisterEffect(e1)

            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
            e2:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
            bc:RegisterEffect(e2)
		end
    
        local tc=Duel.GetAttackTarget()
        if tc and tc:IsRelateToBattle() then
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
			tc:RegisterEffect(e1)

            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
            e2:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
            tc:RegisterEffect(e2)
        end

    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
        local tc=Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1,1,false,nil)
        if tc then
            Duel.HintSelection(tc)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(1000)
            tc:RegisterEffect(e1)
        end
		
	end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end
