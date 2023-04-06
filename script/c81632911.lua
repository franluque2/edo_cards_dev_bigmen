--Promise for Power
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
local LOCATION_HDG=LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE
local LOCATION_RMV_GRV=LOCATION_REMOVED+LOCATION_GRAVE
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		local c=e:GetHandler()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetOperation(s.adop)
	Duel.RegisterEffect(e2,tp)
	end
	e:SetLabel(1)
end

function not_silent_pain_filter(c)
return not c:IsCode(511002742)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,not_silent_pain_filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.place_pain(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.place_pain(e,tp,eg,ep,ev,re,r,rp)
	local pain=Duel.CreateToken(tp,81632173)
	Duel.SendtoGrave(pain,REASON_EFFECT)
end
function s.silent_pain_filter(c)
	return c:IsCode(511002742)
end


function s.torment_or_space_filter(c)
	return (c:IsCode(511002744) or c:IsCode(511002743)) and c:IsAbleToHand()
end
function s.anchor_knight_filter(c)
	return c:IsCode(511001385) and c:IsFaceup()
end
function s.violent_salvage_filter(c,e,tp)
	return c:IsCode(511001386) and c:IsSSetable()
end
function s.fool_clown_filter(c)
	return c:IsCode(511009200) and c:IsFaceup()
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(ep,id+1)>0 and Duel.GetFlagEffect(ep,id+2)>0 and Duel.GetFlagEffect(ep,id+3)>0 then return end
	--Boolean checks for the activation condition: b1, b2, b3
	local b1=Duel.GetFlagEffect(ep,id+1)==0
			and Duel.IsExistingMatchingCard(s.silent_pain_filter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.torment_or_space_filter,tp,LOCATION_DECK,0,1,nil)
			and not Duel.IsExistingMatchingCard(not_silent_pain_filter,tp,LOCATION_GRAVE,0,1,nil)

	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(s.anchor_knight_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.violent_salvage_filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

	local b3=Duel.GetFlagEffect(ep,id+3)==0
			and Duel.IsExistingMatchingCard(s.fool_clown_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,3,nil)

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(ep,id+1)==0
			and Duel.IsExistingMatchingCard(s.silent_pain_filter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.torment_or_space_filter,tp,LOCATION_DECK,0,1,nil)
			and not Duel.IsExistingMatchingCard(not_silent_pain_filter,tp,LOCATION_GRAVE,0,1,nil)

	--Boolean check for effect2:
	local b2=Duel.GetFlagEffect(ep,id+2)==0
			and Duel.IsExistingMatchingCard(s.anchor_knight_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.violent_salvage_filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

	--Boolean check for effect3:
	local b3=Duel.GetFlagEffect(ep,id+3)==0
			and Duel.IsExistingMatchingCard(s.fool_clown_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,3,nil)

	--This auxiliary function should simplify what you did with all the Duel.SelectOption you used previously:
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,2)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end

--op=0, Once per turn, if "Silent Pain" is your GY: You can add 1 "Silent Torment" or 1 "Silent Space" from your Deck to your Hand
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.torment_or_space_filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)

end

--op=1, Once per Duel, if you control "Anchor Knight" you can set 1 "Violent Salvage" from your Deck or GY to your Spell/Trap Zone.
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.violent_salvage_filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

--op=2, Once per turn, if you control "Fool Clown", you can banish any number of cards from your GY, then Special Summon 1 "Rough Exploder" for every 3 cards banished, if you banished 6 or more cards, you can also place 1 "Rough Fight" in your GY from outside the duel.
function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	local banish_max=Duel.GetLocationCount(tp,LOCATION_MZONE)*3
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_GRAVE,0,3,banish_max,nil)
	local cg=Duel.Remove(g,POS_FACEUP,REASON_COST)
	if cg>0 then
		for i = 1,math.floor(cg/3),1
		do
			local exploder=Duel.CreateToken(tp,511002098)
			Duel.SpecialSummon(exploder,0,tp,tp,false,false,POS_FACEUP)
		end
		if cg>6 then
			local roughfight=Duel.CreateToken(tp,511002097)
			Duel.SendtoGrave(roughfight,REASON_EFFECT)
		end
	end
	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
