--Tech.Genex
local s,id=GetID()


function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,1,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id+1,0,0,0)


		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2,tp)
		end
e:SetLabel(1)
end

	function s.genexcontroller_gy_filter(c)
		return c:IsCode(68505803) and c:IsAbleToDeck()
	end

	function s.genexcontroller_send_filter(c)
		return c:IsCode(68505803) and c:IsAbleToGraveAsCost()
	end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.genexcontroller_gy_filter, tp, LOCATION_GRAVE, 0, 1, nil)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_CARD,tp,id)
		local g=Duel.SelectMatchingCard(tp,s.genexcontroller_gy_filter,tp,LOCATION_GRAVE,0,1,1,false,nil)
		if #g then
			Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
		end
	end
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.summon_genex_controller(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

		--At the start of the duel, Special Summon 1 "Genex Controller" from outside the duel.
function s.summon_genex_controller(e,tp,eg,ep,ev,re,r,rp)
	local controller=Duel.CreateToken(tp,68505803)
	Duel.SpecialSummon(controller,0,tp,tp,false,false,POS_FACEUP)
end

function s.genex_filter_deck(c)
	return c:IsSetCard(0x2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.genex_tuner_filter(c)
	return c:IsSetCard(0x2) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsType(TYPE_TUNER)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPT check
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+3)>0 and Duel.GetFlagEffect(tp, id+4)>0 then return end

	--Once per turn, you can send 1 "Genex Controller" from your Hand or Deck to the GY, then add 1 "Genex" monster from your Deck to your Hand.


	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.genexcontroller_send_filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.genex_filter_deck,tp,LOCATION_DECK,0,1,nil)

			--Once per turn, you can target 1 "Genex" Tuner monster you control and declare a level from 1 to 3,
		-- until the end of this turn, that becomes that level, it's name becomes "Genex Controller" and gains the following effect:

	local b2=Duel.GetFlagEffect(tp, id+3)==0
		and Duel.IsExistingMatchingCard(s.genex_tuner_filter,tp,LOCATION_MZONE,0,1,nil)

	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	--Once per turn, you can send 1 "Genex Controller" from your Hand or Deck to the GY, then add 1 "Genex" monster from your Deck to your Hand.


	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.genexcontroller_send_filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.genex_filter_deck,tp,LOCATION_DECK,0,1,nil)

			--Once per turn, you can target 1 "Genex" Tuner monster you control and declare a level from 1 to 3,
		-- until the end of this turn, that becomes that level, it's name becomes "Genex Controller" and gains the following effect:

	local b2=Duel.GetFlagEffect(tp, id+3)==0
		and Duel.IsExistingMatchingCard(s.genex_tuner_filter,tp,LOCATION_MZONE,0,1,nil)

		local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									  {b2,aux.Stringid(id,1)})
		op=op-1

	if op==0 then
		local tg=Duel.SelectMatchingCard(tp, s.genexcontroller_send_filter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1,false,nil)
		if Duel.SendtoGrave(tg, REASON_EFFECT) then
			local g=Duel.SelectMatchingCard(tp, s.genex_filter_deck, tp, LOCATION_DECK, 0, 1, 1,false,nil)
			Duel.SendtoHand(g, tp, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, g)
		end
			--opt register
			Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	elseif op==1 then
		local tg=Duel.SelectMatchingCard(tp, s.genex_tuner_filter, tp, LOCATION_MZONE, 0, 1, 1,false,nil):GetFirst()
			if tg then
				local lv=Duel.AnnounceLevel(tp,1,3)

				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
				tg:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CHANGE_CODE)
				e2:SetValue(68505803)
				tg:RegisterEffect(e2)

				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
				e3:SetType(EFFECT_TYPE_IGNITION)
				e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CLIENT_HINT)
				e3:SetRange(LOCATION_MZONE)
				e3:SetCountLimit(1)
				e3:SetTarget(s.sctg)
				e3:SetOperation(s.scop)
				e3:SetDescription(aux.Stringid(id, 2))
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tg:RegisterEffect(e3)
			end
		Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end

function s.filter(c,e,tp,lv)
	return c:IsFaceup() and c:GetLevel()>0
		and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+c:GetLevel())
end
function s.scfilter(c,e,tp,lv)
	return c:IsSetCard(0x2) and c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local lv=e:GetHandler():GetOriginalLevel()
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
		return #pg<=0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,e,tp,lv) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e,tp,lv)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) or #pg>0 then return end
	local g=Group.FromCards(c,tc)
	if Duel.SendtoGrave(g,REASON_EFFECT)==2 and c:GetLevel()>0 and c:IsLocation(LOCATION_GRAVE)
		and tc:GetPreviousLevelOnField()>0 and tc:IsLocation(LOCATION_GRAVE) then
		local lv=c:GetPreviousLevelOnField()+tc:GetPreviousLevelOnField()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
		local tc=sg:GetFirst()
		if tc then
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
