--Goha Mastermind
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

		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e8:SetCondition(s.flipcon3)
		e8:SetOperation(s.flipop3)
		e8:SetCountLimit(1)
		Duel.RegisterEffect(e8,tp)


	end
	e:SetLabel(1)
end

function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local actor=Duel.CreateToken(tp, 160204006)
	Duel.SpecialSummon(actor,0,tp,tp,false,false,POS_FACEUP)
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



function s.monsterfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

function s.fusionfilter(c)
	return c:IsCode(160204050) and c:IsAbleToHand()
end

function s.exfilter(c,e,tp)
	return c.material and c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end

function s.addfilter(c,e,tp,fc)
	return c:IsAbleToHand() and c:IsCode(table.unpack(fc.material))
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPT check
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+3)>0 and Duel.GetFlagEffect(tp, id+4)>0 then return end
	--
	-- Once per turn, you can send the top 2 cards of your Deck to the GY, then declare 1 type.
	--Until the end of this turn, monsters your opp controls become that type up to the number of cyborgs you have
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
			and Duel.GetMatchingGroupCount(s.monsterfilter, tp, 0, LOCATION_MZONE, nil)>0
			and Duel.IsExistingMatchingCard(s.fucyborgfilter, tp, LOCATION_MZONE, 0, 1,nil)


-- Once per turn, you can discard 1 card, add 1 "Fusion" from your Deck to your Hand.
local b2=Duel.GetFlagEffect(tp, id+3)==0
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler(),REASON_EFFECT)
		and Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_DECK,0,1,nil)

		--Once per turn, you send the top card of your Deck to the GY, reveal 1 Fusion monster in your Extra Deck,
		-- add one of the listed Fusion Materials from your GY to your Hand.

		local b3=Duel.GetFlagEffect(tp, id+4)==0
			and Duel.IsPlayerCanDiscardDeckAsCost(tp,1)
			and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end

function s.fucyborgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBORG)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	-- Once per turn, you can send the top 2 cards of your Deck to the GY, then declare 1 type.
	--Until the end of this turn, monsters your opp controls become that type up to the number of cyborgs you have
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
			and Duel.GetMatchingGroupCount(s.monsterfilter, tp, 0, LOCATION_MZONE, nil)>0
			and Duel.IsExistingMatchingCard(s.fucyborgfilter, tp, LOCATION_MZONE, 0, 1,nil)


	-- Once per turn, you can discard 1 card, add 1 "Fusion" from your Deck to your Hand.
	local b2=Duel.GetFlagEffect(tp, id+3)==0
			and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler(),REASON_EFFECT)
			and Duel.IsExistingMatchingCard(s.fusionfilter,tp,LOCATION_DECK,0,1,nil)

			--Once per turn, you send the top card of your Deck to the GY, reveal 1 Fusion monster in your Extra Deck,
			-- add one of the listed Fusion Materials from your GY to your Hand.

			local b3=Duel.GetFlagEffect(tp, id+4)==0
				and Duel.IsPlayerCanDiscardDeckAsCost(tp,1)
				and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)

		local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									  {b2,aux.Stringid(id,1)},
											{b3,aux.Stringid(id, 2)})
		op=op-1

	if op==0 then
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
		local rc=Duel.AnnounceRace(tp,1,RACE_ALL)

		local num=Duel.GetMatchingGroupCount(s.fucyborgfilter, tp, LOCATION_MZONE, 0, nil)

		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
		local g=Duel.SelectMatchingCard(tp, s.monsterfilter, tp, 0, LOCATION_MZONE, 1,num,false,nil)

		for tc in g:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(rc)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)			
		end
			--opt register
			Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	elseif op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
		if Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.fusionfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
	end
			Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
	elseif op==2 then
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local cg=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #cg==0 then return end
		Duel.ConfirmCards(1-tp,cg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,cg:GetFirst())
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
		Duel.RegisterFlagEffect(tp, id+4, 0, 0, 0)
	end
end
