--Scarred Fusion Veteran
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

		--other passive duel effects go here

		--uncomment (remove the --) the line below to make it a rush skill
		--bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCountLimit(1)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCondition(s.setcon)
		e3:SetOperation(s.setop)
		Duel.RegisterEffect(e3,tp)


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

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(ep,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)



	local tc=Duel.CreateToken(tp, 81632253)

	 local tpe=tc:GetType()
	 local te=tc:GetActivateEffect()
	 if te then
		 local con=te:GetCondition()
		 local co=te:GetCost()
		 local tg=te:GetTarget()
		 local op=te:GetOperation()
		 Duel.ClearTargetCard()
		 e:SetCategory(te:GetCategory())
		 e:SetProperty(te:GetProperty())
		 if tpe&TYPE_FIELD~=0 then
			 local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
			 if Duel.IsDuelType(DUEL_1_FIELD) then
				 if fc then Duel.Destroy(fc,REASON_RULE) end
				 fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				 if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			 else
				 fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				 if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			 end
		 end
		 Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		 Duel.Hint(HINT_CARD,0,tc:GetCode())
		 tc:CreateEffectRelation(te)
		 if tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD==0 then
			 tc:CancelToGrave(false)
		 end
		 if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
		 if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end

		 Duel.BreakEffect()
		 if op then op(te,tp,eg,ep,ev,re,r,rp) end
		 tc:ReleaseEffectRelation(te)

	 end


end

function s.pwarriorfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsCode(42035044)
end

function s.csentinelfilter(c)
	return c:IsAbleToHand() and c:IsCode(511002703)
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.pwarriorfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
						and Duel.IsExistingMatchingCard(s.csentinelfilter,tp,LOCATION_DECK,0,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above


	s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.SelectMatchingCard(tp, s.pwarriorfilter, tp, LOCATION_DECK+LOCATION_HAND, 0, 1,1,nil)
	if Duel.SendtoGrave(g, REASON_COST) then
		local tc=Duel.SelectMatchingCard(tp, s.csentinelfilter, tp, LOCATION_DECK, 0, 1,1,nil)
		if tc then
			Duel.SendtoHand(tc, tp, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, tc)
		end
	end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.isbbfusionfilter(c)
	return c:IsSetCard(0x50b) and c:IsType(TYPE_FUSION)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetFlagEffect(tp,id+2)>0) then return false end
	local g=Duel.IsExistingMatchingCard(s.isbbfusionfilter, tp, LOCATION_ONFIELD, 0, 1,nil)
	return Duel.GetTurnPlayer()==tp and g and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and Duel.IsExistingMatchingCard(s.conttrapfiler,tp,LOCATION_DECK,0,1,nil)
end

local MakeCheck=function(setcodes,archtable,extrafuncs)
	return function(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if extrafuncs then
			for _,func in pairs(extrafuncs) do
				if Card[func](c,sc,sumtype,playerid) then return true end
			end
		end
		if setcodes then
			for _,setcode in pairs(setcodes) do
				if c:IsSetCard(setcode,sc,sumtype,playerid) then return true end
			end
		end
		if archtable then
			if c:IsSummonCode(sc,sumtype,playerid,table.unpack(archtable)) then return true end
		end
		return false
	end
end



local set_traps={81632953}
Card.hasbeenset=MakeCheck(nil,set_traps)

function s.conttrapfiler(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable() and c:IsBeastBorgMedal() and not c:hasbeenset()
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)

	local tc=Duel.GetMatchingGroup(s.conttrapfiler, tp, LOCATION_DECK, 0,nil)
	if #tc>0 then
		Duel.Hint(HINT_CARD, tp, id)
		local cardnumber=Duel.GetRandomNumber(1, #tc )
		local g=tc:GetFirst()
		while g do
			if cardnumber==1 then
				table.insert(set_traps,g:GetCode())
				Duel.SSet(tp, g)
			end
			cardnumber=cardnumber-1
			g=tc:GetNext()
		end
	end
	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
