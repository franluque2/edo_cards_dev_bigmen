--Wrath of G.O.D.
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

	aux.GlobalCheck(s,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.startop)
		Duel.RegisterEffect(ge2,0)
	end)

	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)

end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1 then return end

	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD|LOCATION_REMOVED|LOCATION_GRAVE, LOCATION_ONFIELD|LOCATION_REMOVED|LOCATION_GRAVE, 1, nil)
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
       
	Duel.Hint(HINT_CARD,tp,id)
	s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x7f,0x7f,nil)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(511010208,RESET_PHASE+PHASE_END,0,1,tc:GetLocation())
		tc:RegisterFlagEffect(511010209,RESET_PHASE+PHASE_END,0,1,tc:GetControler())
		tc:RegisterFlagEffect(511010210,RESET_PHASE+PHASE_END,0,1,tc:GetPosition())
		tc:RegisterFlagEffect(511010211,RESET_PHASE+PHASE_END,0,1,tc:GetSequence())
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD|LOCATION_REMOVED|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_REMOVED|LOCATION_GRAVE,nil)
	for rc in aux.Next(rg) do
		if rc:GetFlagEffectLabel(511010208)==LOCATION_HAND then
			Duel.SendtoHand(rc,rc:GetFlagEffectLabel(511010209),REASON_EFFECT)
		elseif rc:GetFlagEffectLabel(511010208)==LOCATION_GRAVE then
			Duel.SendtoGrave(rc,REASON_EFFECT,rc:GetFlagEffectLabel(511010209))
		elseif rc:GetFlagEffectLabel(511010208)==LOCATION_REMOVED then
			Duel.Remove(rc,rc:GetPreviousPosition(),REASON_EFFECT,rc:GetFlagEffectLabel(511010209))
		elseif rc:GetFlagEffectLabel(511010208)==LOCATION_DECK then
			Duel.SendtoDeck(rc,rc:GetFlagEffectLabel(511010209),2,REASON_EFFECT)
		elseif rc:GetFlagEffectLabel(511010208)==LOCATION_EXTRA then
			Duel.SendtoDeck(rc,rc:GetFlagEffectLabel(511010209),0,REASON_EFFECT)
		else
			if rc:IsStatus(STATUS_LEAVE_CONFIRMED) then
				rc:CancelToGrave()
			end
			local loc=rc:GetFlagEffectLabel(511010208)
			if rc:IsType(TYPE_FIELD) then
				loc=LOCATION_FZONE
			end
			Duel.MoveToField(rc,rc:GetFlagEffectLabel(511010209),rc:GetFlagEffectLabel(511010209),loc,rc:GetFlagEffectLabel(511010210),true)
			if rc:GetSequence()~=rc:GetFlagEffectLabel(511010211) then
				Duel.MoveSequence(rc,rc:GetFlagEffectLabel(511010211))
			end
			if rc:GetPosition()~=rc:GetFlagEffectLabel(511010210) then
				Duel.ChangePosition(rc,rc:GetFlagEffectLabel(511010210),rc:GetFlagEffectLabel(511010210),rc:GetFlagEffectLabel(511010210),rc:GetFlagEffectLabel(511010210),true,true)
			end
		end
	end

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

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