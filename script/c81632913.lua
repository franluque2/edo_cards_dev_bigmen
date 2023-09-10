--D-Scale Portal
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
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetCondition(s.spcon)
		e3:SetOperation(s.spop)
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
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.water_discard_filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end

function s.dsacle_search_filter(c)
	return c:IsSetCard(0x579) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.water_banish_filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost()
end

function s.dscale_summon_filter(c,e,tp)
	return c:IsSetCard(0x579) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 then return end
	local g=Duel.GetMatchingGroup(s.water_banish_filter, tp, LOCATION_GRAVE, 0, nil)
	local g2=Duel.GetMatchingGroup(s.dscale_summon_filter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, nil,e,tp)
	--Boolean checks for the activation condition: b1, b2, b3
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.water_discard_filter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.dsacle_search_filter,tp,LOCATION_DECK,0,1,nil)


	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.water_banish_filter,tp,LOCATION_GRAVE,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.dscale_summon_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
			and (#g+#g2)>1

	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.GetMatchingGroup(s.water_banish_filter, tp, LOCATION_GRAVE, 0, nil)
	local g2=Duel.GetMatchingGroup(s.dscale_summon_filter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, nil,e,tp)

	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.water_discard_filter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.dsacle_search_filter,tp,LOCATION_DECK,0,1,nil)


	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.water_banish_filter,tp,LOCATION_GRAVE,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.dscale_summon_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
			and (#g+#g2)>0

	--This auxiliary function should simplify what you did with all the Duel.SelectOption you used previously:
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

--op=0, discard any number of WATER monsters in your hand, then add "D-Scale" monsters from your Deck to your Hand equal to the amount discarded
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local dscales_in_deck=#Duel.GetMatchingGroup(s.dsacle_search_filter,tp,LOCATION_DECK,0,nil)
	local ct=Duel.DiscardHand(tp,s.water_discard_filter,1,dscales_in_deck,REASON_EFFECT+REASON_DISCARD)

	if ct >0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.GetMatchingGroup(s.dsacle_search_filter,tp,LOCATION_DECK,0,nil)
				local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,nil,1,tp,HINTMSG_ATOHAND)
				if #sg==ct then
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
				end
	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

--op=1,  Once per duel, you can banish 1 WATER monster from your GY, Special Summon 1 "D-Scale" monster from either your Hand or GY.
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local cg=Duel.SelectMatchingCard(tp,s.water_banish_filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(cg,POS_FACEUP,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.dscale_summon_filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end


function s.thfilter(c)
	return (c:IsCode(63394872) or c:IsSetCard(0x579)or c:IsCode(511600114)) and c:IsSSetable()
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSetCard(0x579) and c:IsSummonType(SUMMON_TYPE_LINK)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(tp,id+3)>0 then return end
	return eg:IsExists(s.cfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--opt register
		Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
