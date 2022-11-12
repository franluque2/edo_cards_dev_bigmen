--Irreversible Fate

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

		local c=e:GetHandler()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2,tp)


		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetCondition(s.flipcon3)
		e3:SetOperation(s.flipop3)
		Duel.RegisterEffect(e3,tp)

		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_DESTROYED)
		e4:SetCondition(s.flipcon4)
		e4:SetOperation(s.flipop4)
		Duel.RegisterEffect(e4,tp)





end
e:SetLabel(1)
	end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.setfield(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

--At the start of the duel, set 1 "Light Barrier" from outside the duel to your Field Spell Zone.
function s.setfield(e,tp,eg,ep,ev,re,r,rp)
	local field=Duel.CreateToken(tp, 73206827)
	Duel.SSet(tp, field)
end

function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x5)
		and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spcfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x5)
end

function s.spkfilter1(c,rc)
	return c:IsLevel(rc:GetLevel()+1)
end
function s.spcheck1(sg,tp,exg,mg)
	return aux.ReleaseCheckMMZ(sg,tp) and mg:IsExists(s.spkfilter1,1,nil,sg:GetFirst())
end

function s.arcanaforcehighlevelfilter(c)
	return c:IsSetCard(0x5)
		and c:IsType(TYPE_MONSTER)
		and c:IsLevelAbove(8)
end

function s.arcanaforcegravefilter(c,e,tp)
	return c:IsSetCard(0x5)
		and c:IsType(TYPE_MONSTER)
		and c:IsLevelBelow(5)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPT check
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+6)>0 then return end

	local mg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)

--
-- Once per turn, during your Main Phase, you can tribute 1 "Arcana Force" monster to
--Special Summon 1 "Arcana Force" monster from your Hand, Deck or GY whose 1 level higher than the tributed monster.
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.CheckReleaseGroupCost(tp,s.spcfilter1,1,false,s.spcheck1,nil,mg)

-- Once per turn, if you control an "Arcana Force" monster whose level is 8 or higher: You can Special Summon 1 level 5 or lower "Arcana Force" monster from your GY.
local b2=Duel.GetFlagEffect(tp, id+6)==0
		and Duel.IsExistingMatchingCard(s.arcanaforcehighlevelfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.arcanaforcegravefilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)

	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local mg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)

--
-- Once per turn, during your Main Phase, you can tribute 1 "Arcana Force" monster to
--Special Summon 1 "Arcana Force" monster from your Hand, Deck or GY whose 1 level higher than the tributed monster.
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.CheckReleaseGroupCost(tp,s.spcfilter1,1,false,s.spcheck1,nil,mg)

-- Once per turn, if you control an "Arcana Force" monster whose level is 8 or higher: You can Special Summon 1 level 5 or lower "Arcana Force" monster from your GY.
local b2=Duel.GetFlagEffect(tp, id+6)==0
		and Duel.IsExistingMatchingCard(s.arcanaforcehighlevelfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.arcanaforcegravefilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)

		local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									  {b2,aux.Stringid(id,1)})
		op=op-1

	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mg=Duel.SelectReleaseGroupCost(tp,s.spcfilter1,1,1,false,s.spcheck1,nil,mg)
		Duel.Release(mg,REASON_COST)
		local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp):Filter(s.spkfilter1,nil,mg:GetFirst())
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
			--opt register
			Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	elseif op==1 then
		local tc=Duel.SelectMatchingCard(tp, s.arcanaforcegravefilter, tp, LOCATION_GRAVE, 0, 1, 1, nil,e,tp):GetFirst()
			if tc then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
			Duel.RegisterFlagEffect(tp, id+6, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
	end
end


function s.listsarcanaforcefilter(c)
	return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and (Card.ListsArchetype(c,0x5) or
		c:IsCode(100000115,511000601,511000602,100000109,100000114,511001476,100000107,100000108)) and c:IsAbleToHand()
end

function s.arcanaforcefilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x5) and c:IsAbleToHand()
end
-- Once per turn, during each of your Standby Phases, flip a coin and apply one of the following effects:
-- Heads: Add 1 Spell/Trap that lists "Arcana Force" in it's text from your Deck to your hand.
-- Tails: Add 1 "Arcana Force" monster from your Deck to your Hand.

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetTurnPlayer()==tp and not (Duel.GetFlagEffect(tp,id+3)>0) then return end

	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and (Duel.IsExistingMatchingCard(s.listsarcanaforcefilter,tp,LOCATION_DECK,0,1,nil)
			or Duel.IsExistingMatchingCard(s.arcanaforcefilter,tp,LOCATION_DECK,0,1,nil))


	return Duel.GetTurnPlayer()==tp and (b1)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,id)
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
		local sel=Duel.TossCoin(tp,1)
		if sel==1 then
					if #Duel.GetMatchingGroup(s.listsarcanaforcefilter, tp, LOCATION_DECK,0,1,nil)>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
					local g=Duel.SelectMatchingCard(tp,s.listsarcanaforcefilter,tp,LOCATION_DECK,0,1,1,nil)
					if #g>0 then
							Duel.SendtoHand(g, tp, REASON_EFFECT)
							Duel.ConfirmCards(1-tp,g)
					end
				end
	else
		if #Duel.GetMatchingGroup(s.arcanaforcefilter, tp, LOCATION_DECK,0,1,nil)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.arcanaforcefilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
				Duel.SendtoHand(g, tp, REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
		end
	end
	end
	Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
end


function s.lightrulergravefilter(c,e,tp)
	return c:IsCode(05861892)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.darkrulergravefilter(c,e,tp)
	return c:IsCode(69831560)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
--Once per turn, if "Arcana Force EX - The Dark Ruler" you control is destroyed by an opponent's card:
-- You can Special Summon 1 "Arcana Force EX - The Light Ruler" from your GY, ignoring it's summoning conditions.


function s.cfilter1(c,e,tp)
	return c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()~=tp
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsCode(69831560) and Duel.IsExistingMatchingCard(s.lightrulergravefilter, tp, LOCATION_GRAVE, 0, 1, nil,e,tp)
end
function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetFlagEffect(tp, id+5)==0) and eg:IsExists(s.cfilter1,1,nil,e,tp)
end
--

function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,id)
		if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
			local g=Duel.SelectMatchingCard(tp, s.lightrulergravefilter, tp, LOCATION_GRAVE, 0, 1, 1,false,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
			end
			Duel.RegisterFlagEffect(tp, id+5, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
		end

end

--Once per turn, if "Arcana Force EX - The Light Ruler" you control,
--is destroyed by an opponent's card: You can Special Summon 1 "Arcana Force EX - The Dark Ruler" from your GY, ignoring it's summoning conditions.
function s.cfilter2(c,e,tp)
	return c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()~=tp
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsCode(05861892) and Duel.IsExistingMatchingCard(s.darkrulergravefilter, tp, LOCATION_GRAVE, 0, 1, nil,e,tp)
end
function s.flipcon4(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetFlagEffect(tp, id+7)==0) and eg:IsExists(s.cfilter2,1,nil,e,tp)
end
--

function s.flipop4(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,id)
		if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			local g=Duel.SelectMatchingCard(tp, s.darkrulergravefilter, tp, LOCATION_GRAVE, 0, 1, 1,false,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
			end
			Duel.RegisterFlagEffect(tp, id+7, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
		end

end
