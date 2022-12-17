--Ritual of the Mists
local s,id=GetID()
function s.initial_effect(c)
	--skill
		--Activate
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
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--start the game at 14000 lp
	Duel.SetLP(tp,14000)
	local c=e:GetHandler()

	--cannot take more than 2k lp at a time
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.damval)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spop)
	Duel.RegisterEffect(e3,tp)
end

function s.damval(e,re,val,r,rp,rc)
	if val>2000 then return 2000 else return val end
end

function s.specialsummon(e,tp,eg,ep,ev,re,r,rp,code)
	local duelmaster=Duel.CreateToken(tp, code)
	Duel.SpecialSummon(duelmaster,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		duelmaster:RegisterEffect(e1)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetDescription(3001)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(1)
		duelmaster:RegisterEffect(e3)
end

function s.specialsummon_facedown(e,tp,eg,ep,ev,re,r,rp,code)
	local duelmaster=Duel.CreateToken(tp, code)
	Duel.SpecialSummon(duelmaster,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		duelmaster:RegisterEffect(e1)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetDescription(3001)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(1)
		duelmaster:RegisterEffect(e3)
end

function s.setdealruler(e,tp,eg,ep,ev,re,r,rp)
	local deal=Duel.CreateToken(tp, 06850209)
	if Duel.SSet(tp, deal) then
		local bdragon=Duel.CreateToken(tp, 85605684)
		Duel.SendtoDeck(bdragon, tp, SEQ_DECKBOTTOM, REASON_EFFECT)
	end
end

function s.etarget(c)
	return c:GetOverlayCount()~=0
end

function s.limbofield(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.etarget, tp, LOCATION_ONFIELD, 0, nil)
	if #g>0 then
		local tc=g:GetFirst()
		local overlays=tc:GetOverlayGroup()
		tc=g:GetNext()
		while tc do
			overlays:Merge(tc:GetOverlayGroup())
			tc=g:GetNext()
		end
		Duel.SendtoGrave(overlays, REASON_EFFECT)
	end
	local g2=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ONFIELD, 0, nil)
	Duel.RemoveCards(g2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c1=(Duel.GetFlagEffect(tp, id+2)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=12000

	local c2=(Duel.GetFlagEffect(tp, id+3)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=10000

	local c3=(Duel.GetFlagEffect(tp, id+4)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=8000

	local c4=(Duel.GetFlagEffect(tp, id+5)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=6000

	local c5=(Duel.GetFlagEffect(tp, id+6)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=4000

	local c6=(Duel.GetFlagEffect(tp, id+7)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=2000

	return ep==tp and (c1 or c2 or c3 or c4 or c5 or c6)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local c1=(Duel.GetFlagEffect(tp, id+2)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=12000

	local c2=(Duel.GetFlagEffect(tp, id+3)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=10000

	local c3=(Duel.GetFlagEffect(tp, id+4)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=8000

	local c4=(Duel.GetFlagEffect(tp, id+5)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=6000

	local c5=(Duel.GetFlagEffect(tp, id+6)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=4000

	local c6=(Duel.GetFlagEffect(tp, id+7)==0) and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)
						and Duel.GetLP(tp)<=2000

	if c1 then
		s.specialsummon(e,tp,eg,ep,ev,re,r,rp,24128274)
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
	elseif c2 then
		s.specialsummon_facedown(e,tp,eg,ep,ev,re,r,rp,81306586)
	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
	elseif c3 then
		s.specialsummon(e,tp,eg,ep,ev,re,r,rp,30113682)
	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
	elseif c4 then
		s.specialsummon(e,tp,eg,ep,ev,re,r,rp,44203504)
	Duel.RegisterFlagEffect(tp,id+5,0,0,0)
	elseif c5 then
		s.specialsummon(e,tp,eg,ep,ev,re,r,rp,77585513)
	Duel.RegisterFlagEffect(tp,id+6,0,0,0)
	elseif c6 then
		s.limbofield(e,tp,eg,ep,ev,re,r,rp)
		s.specialsummon(e,tp,eg,ep,ev,re,r,rp,511013020)
		s.setdealruler(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+7,0,0,0)
	end
end
