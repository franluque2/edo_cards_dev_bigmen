--The Stars of Life
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
	aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e3:SetCountLimit(1)
		e3:SetCondition(s.spcon)
		e3:SetOperation(s.spop)
		Duel.RegisterEffect(e3,tp)

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetTargetRange(LOCATION_SZONE,0)
		e2:SetCondition(s.immcon)
		e2:SetTarget(s.cspacefilter)
		e2:SetValue(s.efilter)
		Duel.RegisterEffect(e2,tp)

		local c=e:GetHandler()
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCountLimit(1)
		e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e4:SetCondition(s.adcon)
		e4:SetOperation(s.adop)
		Duel.RegisterEffect(e4,tp)
	end
	e:SetLabel(1)
end

function s.evatoken_onfield(c)
	return c:IsCode(64382840) and c:IsFaceup()
end


-- During the Standby Phase, if you do not control "Eva Token",
-- 	You can Special Summon 1 "Eva Token"
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and not Duel.IsExistingMatchingCard(s.evatoken_onfield,tp,LOCATION_ONFIELD,0,1,nil)

	return (b1)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
		s.operation_for_resstd(e,tp,eg,ep,ev,re,r,rp)
end



function s.operation_for_resstd(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		Duel.Hint(HINT_CARD,tp,id)
		local g=Duel.CreateToken(tp, 64382840)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
end

function s.efilter(e,re,rp)
	return e:GetHandlerPlayer()==1-rp
end

function s.cspacefilter(_,c)
	return c:IsCode(511009010)

end

function s.lstarcounterfilter(c)
	return c:IsFaceup() and (c:GetCounter(0x1109)~=0)
end

function s.immcon(e)
	return Duel.IsExistingMatchingCard(s.lstarcounterfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

function s.greedquasarfilter(c)
	return c:IsCode(50263751) and c:IsFaceup() and c:GetCounter(0x1109)>=5
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_MZONE, nil)>2 and Duel.GetFlagEffect(id,tp)~=0 and Duel.IsExistingMatchingCard(s.greedquasarfilter, tp, LOCATION_ONFIELD, 0, 1,nil)
end

--Once per turn, at the start of the Battle Phase, you can banish 1 monster you control. Return that monster to your field during the End Phase.


function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
		Duel.Hint(HINT_CARD,tp,id)
		local quasar=Duel.SelectMatchingCard(tp, s.greedquasarfilter, tp, LOCATION_ONFIELD, 0, 1,1,false,nil):GetFirst()
		quasar:RemoveCounter(tp,0x1109,5,REASON_COST)

		 local tc=Duel.SelectMatchingCard(tp, Card.IsAbleToRemove, tp, LOCATION_MZONE, 0, 1, 1,false,nil):GetFirst()
		 local tc2=Duel.SelectMatchingCard(tp, Card.IsAbleToRemove, tp, 0 , LOCATION_MZONE, 1, 1,false,nil):GetFirst()

			if tc and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetOperation(s.retop)
			Duel.RegisterEffect(e1,tp)
		end


		 if tc2 and Duel.Remove(tc2,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		 local e1=Effect.CreateEffect(e:GetHandler())
		 e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		 e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		 e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		 e1:SetLabelObject(tc2)
		 e1:SetCountLimit(1)
		 e1:SetOperation(s.retop)
		 Duel.RegisterEffect(e1,tp)
	 end
	end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.activate_field(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
end

function s.activate_field(e,tp,eg,ep,ev,re,r,rp)
	local cspace=Duel.CreateToken(tp,81632163)
	Duel.ActivateFieldSpell(cspace,e,tp,eg,ep,ev,re,r,rp)
end




function s.thfilter(c,tp)
	return (c:IsCode(511009012) or c:IsCode(511009011) or c:IsCode(50263751) or c:IsCode(64382839) or Card.ListsCode(c, 64382840)) and c:IsLevelAbove(1)
		and c:IsAbleToHand()
		and Duel.IsCanRemoveCounter(tp,1,1,0x1109,c:GetLevel(),REASON_COST)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	--Boolean checks for the activation condition: b1, b2
	local b1=Duel.GetFlagEffect(ep,id+1)==0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp)

	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(ep,id+1)==0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	-- elseif op==1 then
	-- 	s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.filter(c,lv)
	return  (c:IsCode(511009012) or c:IsCode(511009011) or c:IsCode(50263751) or c:IsCode(64382839) or Card.ListsCode(c, 64382840)) and c:IsLevel(lv)
		and c:IsAbleToHand()
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,tp)
	local lvt={}
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	Duel.RemoveCounter(tp,1,1,0x1109,lv,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,lv)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
