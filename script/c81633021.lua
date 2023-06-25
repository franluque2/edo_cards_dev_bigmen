--Panik Attack!
--Skill Template
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
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCondition(s.yamicon)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,00062121))
	e3:SetValue(1)
    Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    Duel.RegisterEffect(e4,tp)


    local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetTargetRange(LOCATION_MZONE,0)
    e6:SetCondition(s.yamicon)
	e6:SetTarget(aux.TargetBoolFunction(Card.IsCode,00062121))
	e6:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
    e6:SetValue(1)
    Duel.RegisterEffect(e6,tp)


    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetCondition(s.yamicon)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.valatk)
    Duel.RegisterEffect(e2,tp)
	--Def
	local e7=e2:Clone()
	e7:SetCode(EFFECT_UPDATE_DEFENSE)
    e7:SetValue(s.valdef)
    Duel.RegisterEffect(e7,tp)

	--sp increase stats
	local e8=Effect.CreateEffect(e:GetHandler())
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCountLimit(1)
	e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e8:SetCondition(s.inccon)
	e8:SetOperation(s.incop)
	Duel.RegisterEffect(e8,tp)

	local e9=Effect.CreateEffect(e:GetHandler())
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_ADD_RACE)
	e9:SetTargetRange(LOCATION_MZONE,0)
	e9:SetTarget(function(_,c)  return s.darkfiendfilter(c) end)
	e9:SetValue(RACE_ZOMBIE)
	Duel.RegisterEffect(e9,tp)


	local e10=Effect.CreateEffect(e:GetHandler())
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e10:SetTargetRange(LOCATION_MZONE,0)
	e10:SetCondition(s.yamicon)
	e10:SetTarget(function(_,c) return s.nonefflevelfivedarkfiendfilter(c) end)
	e10:SetValue(1)
	Duel.RegisterEffect(e10,tp)

	local e11=Effect.CreateEffect(e:GetHandler())
		e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e11:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e11:SetCountLimit(1)
		e11:SetCondition(s.spcon)
		e11:SetOperation(s.spop)
		Duel.RegisterEffect(e11,tp)

	end
	e:SetLabel(1)
end

function s.reapcardfilter(c,e,tp)
	return c:IsCode(33066139) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false,POS_FACEDOWN_DEFENSE)
end

function s.notcastlefilter(c)
	return c:IsFacedown() or not c:IsCode(00062121)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.GetMatchingGroupCount(s.notcastlefilter, tp, LOCATION_MZONE, 0, nil)==0) and (not Duel.GetFlagEffect(id+5,tp)~=0) and Duel.IsExistingMatchingCard(s.darkillufilter, tp, LOCATION_MZONE, 0, 1,nil)
		and Duel.IsExistingMatchingCard(s.reapcardfilter, tp, LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED, 0, 1,nil,e,tp)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
		Duel.Hint(HINT_CARD,tp,id)

		local count=0
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft1>0 then
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=1 end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.reapcardfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,ft1,ft1,nil,e,tp)
			if #g>0 then
				local tc=g:GetFirst()
				while tc do
					Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
					tc=g:GetNext()
					count=count+1
				end
			end
		end
		if count>0 then Duel.SpecialSummonComplete() end
		
		Duel.RegisterFlagEffect(tp, id+5, 0, 0, 0)
	end
end

function s.darkillufilter(c)
	return c:IsCode(00062121) and c:IsFaceup()
end

function s.nonefflevelfivedarkfiendfilter(c)
	return s.darkfiendfilter(c) and c:IsLevel(5) and c:HasLevel() and not c:IsType(TYPE_EFFECT)
end
function s.darkfiendfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end

function s.inccon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetTurnPlayer()==tp and (Duel.GetMatchingGroupCount(s.darkfiendfilter, tp, LOCATION_MZONE, 0, nil)==0) and not (Duel.GetFlagEffect(tp,id+4)>0) then return end

	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.darkillufilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.incop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local g=Duel.GetMatchingGroup(s.darkfiendfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(200)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end

	Duel.RegisterFlagEffect(tp, id+4, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
end

function s.valatk(e,c)
	local r=c:GetRace()
	if (r&RACE_FIEND~=0) and (c:GetAttribute()&ATTRIBUTE_DARK~=0) and not c:IsType(TYPE_EFFECT) then
        return math.floor(c:GetBaseAttack()*0.3)
	else return 0 end
end

function s.valdef(e,c)
	local r=c:GetRace()
	if (r&RACE_FIEND~=0) and (c:GetAttribute()&ATTRIBUTE_DARK~=0) and not c:IsType(TYPE_EFFECT) then
        return math.floor(c:GetBaseDefense()*0.3)
	else return 0 end
end

function s.yamifilter(c)
	return c:IsFaceup() and c:IsCode(59197169)
end

function s.yamicon(e)
	return Duel.IsExistingMatchingCard(s.yamifilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

    local yami=Duel.CreateToken(tp, 59197169)
    Duel.ActivateFieldSpell(yami,e,tp,eg,ep,ev,re,r,rp)

    local castle=Duel.CreateToken(tp, 00062121)
    Duel.SpecialSummonStep(castle, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEDOWN_DEFENSE)

    Duel.SpecialSummonComplete()
    Duel.ChangePosition(castle,POS_FACEUP_DEFENSE)

end


function s.levelfivedarkfiendfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(5) and c:HasLevel() and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false, POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.darkillufilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.levelfivedarkfiendfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp)

--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
and Duel.IsExistingMatchingCard(s.darkillufilter,tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.IsExistingMatchingCard(s.levelfivedarkfiendfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)


	local count=0
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft1>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=1 end
		local g=Duel.GetMatchingGroup(s.levelfivedarkfiendfilter, tp, LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA, 0, nil, e, tp)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ft1,aux.dncheck,1,tp,HINTMSG_SPSUMMON)

		for tc in aux.Next(sg) do
			if tc:IsType(TYPE_FUSION) and tc:GetLocation()==LOCATION_EXTRA then
				tc:SetMaterial(nil)
				Duel.SpecialSummonStep(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
				tc:CompleteProcedure()
			else if tc:GetLocation()==LOCATION_GRAVE then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(3300)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
				e1:SetValue(LOCATION_REMOVED)
				tc:RegisterEffect(e1,true)
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)

			else
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
			end
			
		end
		count=count+1
	end
	if count>0 then
		Duel.SpecialSummonComplete()
	end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end
