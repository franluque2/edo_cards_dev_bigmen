--Advanced Darkness
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
		Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DESTROY_REPLACE)
		e2:SetTarget(s.desreptg)
		e2:SetValue(s.desrepval)
		e2:SetOperation(s.desrepop)
        e2:SetCountLimit(1)
		Duel.RegisterEffect(e2,tp)


        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATION_ALL,0)
        e5:SetTarget(function(_,c)  return c:IsOriginalCode(36795102) end)
        e5:SetValue(SET_ADVANCED_CRYSTAL_BEAST)
        Duel.RegisterEffect(e5,tp)
		
		local e6=e5:Clone()
		e6:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e6:SetValue(ATTRIBUTE_DARK)
		Duel.RegisterEffect(e6,tp)


		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_MOVE)
		e3:SetCondition(s.thcond)
		e3:SetOperation(s.limop)
        Duel.RegisterEffect(e3, tp)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_CHAIN_END)
		e4:SetOperation(s.limop2)
        Duel.RegisterEffect(e4, tp)

	end
	e:SetLabel(1)
end


function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsLocation(LOCATION_SZONE) and not c:IsPreviousLocation(LOCATION_SZONE)
		and c:IsControler(tp) and c:GetSequence()<5
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
	return (tp~=rp) or (not e:GetHandler():IsCode(10938846))
end

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(CARD_ADVANCED_DARK) and c:GetReasonPlayer()~=tp and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e,tp)
	return c:IsSetCard(SET_ADVANCED_CRYSTAL_BEAST) and c:IsAbleToGrave()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.cfilter(c)
	return c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard(SET_ADVANCED_CRYSTAL_BEAST) and c:IsAbleToGrave()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sg=g:FilterSelect(tp,s.desfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		Duel.HintSelection(sg)
		return true
	else return false end
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REPLACE)
end



function s.field_filter(c)
	return c:IsType(TYPE_FIELD)
end
function s.activate_field(e,tp,eg,ep,ev,re,r,rp)
	local field=Duel.SelectMatchingCard(tp,s.field_filter,tp,LOCATION_DECK,0,1,1,nil)
	if #field>0 then
		Duel.ActivateFieldSpell(field:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
	end
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    s.activate_field(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,0,0,0)
end
