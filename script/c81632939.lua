--Glory to the Heavy Cavalry Duel Club
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

		--At the start of the Duel, Activate a fieldspell from your deck

		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_PREDRAW)
		e8:SetCondition(s.flipcon3)
		e8:SetOperation(s.flipop3)
		e8:SetCountLimit(1)
		Duel.RegisterEffect(e8,tp)


	end
	e:SetLabel(1)
end

function s.fieldfilter(c)
	return c:IsType(TYPE_FIELD)
end

function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
	and Duel.IsExistingMatchingCard(s.fieldfilter, tp, LOCATION_DECK, 0, 1, nil)
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
	local field=Duel.SelectMatchingCard(tp, s.fieldfilter, tp, LOCATION_DECK, 0, 1, 1,false,nil)
	if field then
		Duel.ActivateFieldSpell(field:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
	end
end


function s.getcarddraw(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0) < 5 then
		return 5-Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)
	else
		return 1
end
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

function s.znval(e)
	return ~(0x60)
end


function s.disabledzones(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandlerPlayer()==tp then
			return 0x00001111
	else
			return 0x11110000
	end
end


function s.addfilter(c,e,tp,fc)
	return c:IsAbleToHand() and c:IsType(TYPE_MAXIMUM) and c:IsAttribute(ATTRIBUTE_EARTH)
end

function s.bwheelfilter(c)
	return c:IsCode(81632176) and c:IsSSetable()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPT check
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+3)>0 and Duel.GetFlagEffect(tp, id+4) then return end
	--
-- Once per turn, if you do not control a Field Spell,
--you can send the top 2 cards of your Deck to the GY, set 1 Field Spell from your GY to your Field Spell Zone.
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
			and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_GRAVE,0,1,nil)
			and not Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_FZONE,0,1,nil)


-- Once per duel, you can add any number of EARTH Maximum monsters from
-- your GY to your Hand up to the number of Field Spells on your Field and in your GY.
local b2=Duel.GetFlagEffect(tp, id+3)==0
		and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_GRAVE+LOCATION_FZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_GRAVE,0,1,nil)

		--Once per turn, you can reveal 1 "Bucket-Wheel Force" in your Hand, set that card.
		--Place 1 "Shield Boring Kong", "Night Vision the Phantom Pigeon" and 1 "Beast Drive Mega Elephant" on the top of your Deck, then set 1 "Gold Rush" to your Spell/Trap Zone from outside the duel.
		--During the next turn after this effect was applied, all monsters your opponent controls that were Special Summoned from the Extra Deck that do not have a Level are treated as Level 8.
		--During your Opponent's End Phase, all "Shield Boring Kong", "Night Vision the Phantom Pigeon" and "Beast Drive Mega Elephant" in your GY and Deck disintegrate (they dissapear from the duel),
		--then if you control a face-down "Gold Rush", disintegrate that card (it dissapears from the duel).

		local b3=Duel.GetFlagEffect(tp, id+4)==0
			and Duel.IsExistingMatchingCard(s.bwheelfilter, tp, LOCATION_HAND, 0, 1, nil)
			and Duel.GetLocationCount(tp, LOCATION_SZONE)>1

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	-- Once per turn, if you do not control a Field Spell,
	--you can send the top 2 cards of your Deck to the GY, set 1 Field Spell from your GY to your Field Spell Zone.
		local b1=Duel.GetFlagEffect(tp,id+2)==0
				and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
				and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_GRAVE,0,1,nil)
				and not Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_FZONE,0,1,nil)


	-- Once per duel, you can add any number of EARTH Maximum monsters from
	-- your GY to your Hand up to the number of Field Spells on your Field and in your GY.
	local b2=Duel.GetFlagEffect(tp, id+3)==0
			and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_GRAVE+LOCATION_FZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_GRAVE,0,1,nil)

			--Once per turn, you can reveal 1 "Bucket-Wheel Force" in your Hand, set that card.
			--Place 1 "Shield Boring Kong", "Night Vision the Phantom Pigeon" and 1 "Beast Drive Mega Elephant" on the top of your Deck, then set 1 "Gold Rush" to your Spell/Trap Zone from outside the duel.
			--During the next turn after this effect was applied, all monsters your opponent controls that were Special Summoned from the Extra Deck that do not have a Level are treated as Level 8.
			--During your Opponent's End Phase, all "Shield Boring Kong", "Night Vision the Phantom Pigeon" and "Beast Drive Mega Elephant" in your GY and Deck disintegrate (they dissapear from the duel),
			--then if you control a face-down "Gold Rush", disintegrate that card (it dissapears from the duel).

			local b3=Duel.GetFlagEffect(tp, id+4)==0
				and Duel.IsExistingMatchingCard(s.bwheelfilter, tp, LOCATION_HAND, 0, 1, nil)
				and Duel.GetLocationCount(tp, LOCATION_SZONE)>1

		local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									  {b2,aux.Stringid(id,1)},
									{b3,aux.Stringid(id,3)})
		op=op-1

	if op==0 then
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local field=Duel.SelectMatchingCard(tp, s.fieldfilter, tp, LOCATION_GRAVE, 0, 1, 1,false,nil)
		if field then
			Duel.SSet(tp, field)
			--aux.PlayFieldSpell(field:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
		end
			--opt register
			Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	elseif op==1 then
			local fields=Duel.GetMatchingGroup(s.fieldfilter, tp, LOCATION_GRAVE+LOCATION_FZONE, 0, nil)
			local fieldsscount= #fields
			Duel.Hint(HINT_MESSAGE, tp, HINTMSG_ATOHAND)
			local excavpieces=Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_GRAVE, 0, 1, fieldsscount, false, nil)
			Duel.SendtoHand(excavpieces, tp, REASON_EFFECT)
			Duel.ConfirmCards(1-tp, excavpieces)
			Duel.RegisterFlagEffect(tp, id+3, 0, 0, 0)
		elseif op==2 then
				local bucket=Duel.SelectMatchingCard(tp, s.bwheelfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
				if bucket then
					Duel.SSet(tp, bucket)

					local machine1=Duel.CreateToken(tp, 160004032)
					local machine2=Duel.CreateToken(tp, 160005034)
					local machine3=Duel.CreateToken(tp, 160006026)

					Duel.SendtoDeck(machine1, tp, SEQ_DECKTOP, REASON_EFFECT)
					Duel.SendtoDeck(machine2, tp, SEQ_DECKTOP, REASON_EFFECT)
					Duel.SendtoDeck(machine3, tp, SEQ_DECKTOP, REASON_EFFECT)

					local grush=Duel.CreateToken(tp, 81632177)
					Duel.SSet(tp, grush)

					--TODO: NEED TO EXPERIMENT MORE WITH GIVING SHIT LEVELS FUCK

					-- local e2=Effect.CreateEffect(e:GetHandler())
					-- e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
					-- e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					-- e2:SetCode(EVENT_SPSUMMON)
					-- e2:SetCondition(s.statuschangecon)
					-- e2:SetOperation(s.setstatuschange)
					-- e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
					-- Duel.RegisterEffect(e2,tp)

					local e3=Effect.CreateEffect(e:GetHandler())
					e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e3:SetCode(EVENT_PHASE+PHASE_END)
					e3:SetCountLimit(1)
					e3:SetCondition(s.rmcon)
					e3:SetOperation(s.rmop)
					e3:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
					Duel.RegisterEffect(e3,tp)
				end

				Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
end
end

function s.heavycavalryfilter(c)
	return c:IsCode(160004032,160005034,160006026)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and (Duel.IsExistingMatchingCard(s.heavycavalryfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,160208059))
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.GetMatchingGroup(s.heavycavalryfilter, tp,LOCATION_DECK+LOCATION_GRAVE,0, nil)
	local g2=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_SZONE,0, nil,160208059)
	g:Merge(g2)
	if #g==0 then return end
	Duel.SendtoDeck(g, tp, -2, REASON_EFFECT)
end

function s.nolvlfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_EXTRA) and c:IsControler(1-tp) and not c:HasLevel()
end

function s.statuschangecon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.nolvlfilter, 1, nil, tp)
end

function s.setstatuschange(e,tp,eg,ev,ep,re,r,rp)
	local tc = eg:GetFirst()
	for tc in eg:Iter() do

		if tc:IsType(TYPE_LINK) then
			tc:SetStatus(STATUS_NO_LEVEL, false)

			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_REMOVE_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(TYPE_LINK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)

			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_CHANGE_LEVEL)
			e4:SetValue(8)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4)
	end

		if tc:IsType(TYPE_XYZ) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_RANK_LEVEL_S)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)

			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_CHANGE_RANK)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetValue(8)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4)

			Debug.Message(tc:GetLevel())
		end
	end
end
