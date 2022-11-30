--Aria Angel - Angelic Draw
Duel.LoadScript ("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
	--skill
		--Activate
	aux.AddSkillProcedure(c,1,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
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
		Duel.RegisterEffect(e1,tp)

		--enable rush rules
		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

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
end



function s.spelltrapfilter(c)
	return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToDeck()
end


function s.setfilter(c)
	return c:IsSSetable() and c:IsCode(160202024)
end

function s.cleanmenfilter(c)
	return (c:IsCode(160202021) or c:IsCode(160202022) or c:IsCode(160202023) or c:IsCode(81632134)) and c:IsAbleToDeck()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPT check
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+3)>0 then return end
	--
-- Once per turn, you can shuffle 1 Spell/Trap from your Hand into your Deck,
--then set 1 "Bleach Mortar" from from your Deck to your Field.
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.spelltrapfilter, tp, LOCATION_HAND, 0, 1, nil)
			and Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK, 0, 1, nil)
			and Duel.GetLocationCount(tp, LOCATION_SZONE)>0


-- Once per turn, during your Main Phase, you can place up to 1 each of "Clean Beret - Colonel Mop",
-- "Scrubbing Santa Cloth", and "Washsprayer the Cleansketeer" from your GY on top of your Deck in any order.
local b2=Duel.GetFlagEffect(tp, id+3)==0
		and Duel.IsExistingMatchingCard(s.cleanmenfilter,tp,LOCATION_GRAVE,0,1,nil)


	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	-- Once per turn, you can shuffle 1 Spell/Trap from your Hand into your Deck,
	--then set 1 "Bleach Mortar" from from your Deck to your Field.
		local b1=Duel.GetFlagEffect(tp,id+2)==0
				and Duel.IsExistingMatchingCard(s.spelltrapfilter, tp, LOCATION_HAND, 0, 1, nil)
				and Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK, 0, 1, nil)
				and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

	-- Once per turn, during your Main Phase, you can place up to 1 each of "Clean Beret - Colonel Mop",
	-- "Scrubbing Santa Cloth", and "Washsprayer the Cleansketeer" from your GY on top of your Deck in any order.
	local b2=Duel.GetFlagEffect(tp, id+3)==0
			and Duel.IsExistingMatchingCard(s.cleanmenfilter,tp,LOCATION_GRAVE,0,1,nil)


		local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									  {b2,aux.Stringid(id,1)})
		op=op-1

	if op==0 then
			local st=Duel.SelectMatchingCard(tp, s.spelltrapfilter, tp, LOCATION_HAND, 0, 1, 1, false, nil)
			Duel.ConfirmCards(1-tp, st)
			if Duel.SendtoDeck(st, tp, SEQ_DECKSHUFFLE, REASON_EFFECT) then
				local g=Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_DECK, 0, 1, 1, false, nil)
				Duel.SSet(tp, g, tp, true)
			end
			--opt register
			Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	elseif op==1 then
			local tg=Duel.GetMatchingGroup(s.cleanmenfilter,tp,LOCATION_GRAVE,0,nil)
			local g=aux.SelectUnselectGroup(tg,e,tp,1,99,aux.dncheck,1,tp,HINTMSG_TODECK)
			Duel.SendtoDeck(g, tp, SEQ_DECKTOP, REASON_EFFECT)
			Duel.SortDecktop(tp,tp,#g)
			Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
	end
end
