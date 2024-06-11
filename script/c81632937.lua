--Meklord Carrier - "Carreras"

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
end
e:SetLabel(1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.summon_core(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.core_filter(c)
	return c:IsCode(100000067)
end

function s.core_filter_field(c)
	return c:IsCode(100000067) and c:IsFaceup() and c:IsDestructable()
end

function s.core_filter_summon(c,e,tp)
	return c:IsCode(100000067) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.summon_core(e,tp,eg,ep,ev,re,r,rp)
local core=Duel.SelectMatchingCard(tp,s.core_filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
if #core>0 then
	Duel.SpecialSummon(core,0,tp,tp,false,false,POS_FACEUP)
end
end




function s.piecefilter(c)
return (c:IsSetCard(0x50d) or c:IsSetCard(0x507) or c:IsSetCard(0x525) or c:IsSetCard(0x557) or c:IsSetCard(0x562) or c:IsCode(63468625) or
 c:IsCode(4545683) or c:IsCode(31930787) or c:IsCode(68140974)) and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
end

function s.trapfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end

function s.extramfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
--OPT check
if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and
	Duel.GetFlagEffect(tp, id+4)>0 and Duel.GetFlagEffect(tp, id+5)>0
	 and Duel.GetFlagEffect(tp, id+6)>0 then return end
--Boolean checks for the activation condition: b1, b2, b3
--Reveal any number of "Attack", "Carrier", "Guard", "Top", or "∞" monsters in your Hand,
-- place them on the bottom of the deck, then draw that many cards.
local b2=Duel.GetFlagEffect(ep,id+2)==0
		and Duel.IsExistingMatchingCard(s.piecefilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1)

local b3=Duel.GetFlagEffect(ep,id+3)==0
		and Duel.IsExistingMatchingCard(s.core_filter_field,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_DECK,0,3,nil)
		and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

local b4=Duel.GetFlagEffect(ep, id+4)==0
	and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	and Duel.IsExistingMatchingCard(s.core_filter_summon, tp, LOCATION_GRAVE, 0, 1, nil,e,tp)

local b5=Duel.GetFlagEffect(ep, id+5)==0
	and Duel.IsExistingTarget(s.extramfilter, tp, 0, LOCATION_MZONE, 1, nil)

	local b6=Duel.GetFlagEffect(ep, id+6)==0
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 4545683)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000062)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000063)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000064)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000065)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000067)
		and (Duel.GetLP(tp)<=1000)
		and (Duel.GetLocationCount(tp, LOCATION_SZONE)>0)


return aux.CanActivateSkill(tp) and (b2 or b3 or b4 or b5 or b6)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
Duel.Hint(HINT_CARD,tp,id)
--Boolean check for effect 1:

local b2=Duel.GetFlagEffect(ep,id+2)==0
		and Duel.IsExistingMatchingCard(s.piecefilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1)

local b3=Duel.GetFlagEffect(ep,id+3)==0
		and Duel.IsExistingMatchingCard(s.core_filter_field,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_DECK,0,3,nil)
		and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

local b4=Duel.GetFlagEffect(ep, id+4)==0
	and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	and Duel.IsExistingMatchingCard(s.core_filter_summon, tp, LOCATION_GRAVE, 0, 1, nil,e,tp)

	local b5=Duel.GetFlagEffect(ep, id+5)==0
		and Duel.IsExistingMatchingCard(s.extramfilter, tp, 0, LOCATION_MZONE, 1, nil)

	local b6=Duel.GetFlagEffect(ep, id+6)==0
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 4545683)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000062)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000063)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000064)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000065)
		and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 100000067)
		and (Duel.GetLP(tp)<=1000)
		and (Duel.GetLocationCount(tp, LOCATION_SZONE)>0)

		local op=Duel.SelectEffect(tp, {b2,aux.Stringid(id,0)},
		{b3,aux.Stringid(id,1)},
		{b4,aux.Stringid(id,2)},
		{b5,aux.Stringid(id,3)},
		{b6,aux.Stringid(id,4)})

		if op==1 then
			s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
		elseif op==2 then
			s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
		elseif op==3 then
			s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
		elseif op==4 then
			s.operation_for_res4(e,tp,eg,ep,ev,re,r,rp)
		elseif op==5 then
			s.operation_for_res5(e,tp,eg,ep,ev,re,r,rp)
		end
end


--op=1, Reveal any number of "Attack", "Carrier", "Guard", "Top", or "∞" monsters in your Hand,
-- place them on the bottom of the deck, then draw that many cards.
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.SelectMatchingCard(tp,s.piecefilter,tp,LOCATION_HAND,0,1,99,nil)
	if tc then
		Duel.ConfirmCards(1-tp, tc)
		local tcn=Duel.SendtoDeck(tc, tp, SEQ_DECKBOTTOM, REASON_EFFECT)
		if tcn>0 then
			Duel.Draw(tp, tcn, REASON_EFFECT)
		end
		end
Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


--op=2, reveal 3 Trap Cards in your deck with different names,
--randomly select 1 of them, set it to your Spell/Trap Zone, then destroy 1 "Wise Core" you control.
function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(s.trapfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		local cg=Group.CreateGroup()
		for i=1,3 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			g:Remove(Card.IsCode,nil,sg:GetFirst():GetCode())
			cg:Merge(sg)
		end
		Duel.ConfirmCards(1-tp,cg)


	if #cg>=3 then

		local cardnumber=Duel.GetRandomNumber(1, 3 )
		local tc=cg:GetFirst()
		while tc do
			if cardnumber==1 then
				Duel.SSet(tp,tc,tp,false)
			end
			cardnumber=cardnumber-1
			tc=cg:GetNext()
		end
		Duel.ShuffleDeck(tp)
		local core=Duel.SelectMatchingCard(tp, s.core_filter_field, tp, LOCATION_ONFIELD, 0, 1, 1,false,nil)
		if core then
			Duel.Destroy(core, REASON_EFFECT)
		end
	end
	end
Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

--op=3 Special Summon 1 "Wise Core" from your GY, but banish it when it leaves the field.
function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.core_filter_summon),tp,LOCATION_GRAVE,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		sc:RegisterEffect(e1,true)
	end
Duel.RegisterFlagEffect(tp,id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

--op=4 Target a monster your opponent controls that was special summoned from the extra deck it is treated as a synchro while face-up on the field
function s.operation_for_res4(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp, s.extramfilter, tp, 0, LOCATION_MZONE, 1, 1,false,nil):GetFirst()
	if g then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_SYNCHRO)
		g:RegisterEffect(e1)
	end
	Duel.RegisterFlagEffect(tp,id+5,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)

end

function s.operation_for_res5(e,tp,eg,ep,ev,re,r,rp)
	local core1=Duel.CreateToken(tp, 100000055)
	local core2=Duel.CreateToken(tp, 100000066)
	local mkanikle=Duel.CreateToken(tp, 511002517)
	local mcreation=Duel.CreateToken(tp, 100000068)

	Duel.SendtoGrave(core1, REASON_EFFECT)
	Duel.SendtoGrave(core2, REASON_EFFECT)

	Duel.SendtoDeck(mkanikle, tp, SEQ_DECKBOTTOM, REASON_EFFECT)
	Duel.SSet(tp, mcreation)

	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	mcreation:RegisterEffect(e2)

	Duel.RegisterFlagEffect(tp,id+6,0,0,0)
end
