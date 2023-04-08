--Heart of the Cards
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
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


	end
	e:SetLabel(1)
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(s.flipcon2)
	e1:SetOperation(s.flipop2)
	Duel.RegisterEffect(e1,tp)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.atohand(code,tp,group)
	local token=Duel.CreateToken(tp, code)
	group:AddCard(token)
	return group
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+1)==0 and Duel.GetFlagEffect(tp, id+2)<3 and Duel.GetDrawCount(tp)>0
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
	Duel.Hint(HINT_CARD,tp,id)
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
	local gr=Group.CreateGroup()
	gr=s.atohand(55144522,tp,gr) --pog
	gr=s.atohand(12580477,tp,gr) --geki
	gr=s.atohand(83764718,tp,gr) --reborn
	gr=s.atohand(44095762,tp,gr) --mforce
	gr=s.atohand(97631303,tp,gr) --souls
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local card=gr:Select(tp,1,1,nil)
	Duel.SendtoHand(card, tp, REASON_RULE)
	Duel.ConfirmCards(1-tp, card)
	Duel.RegisterFlagEffect(tp, id+2, 0,0,0)
end
	Duel.RegisterFlagEffect(ep,id+1,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
