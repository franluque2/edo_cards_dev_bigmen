--Pattern of Flyweight
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

        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCondition(s.epcon)
		e5:SetOperation(s.epop)
        e5:SetCountLimit(1)
		Duel.RegisterEffect(e5,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(s.spcon)
		e2:SetOperation(s.spop)
		Duel.RegisterEffect(e2,tp)

        local e16=Effect.CreateEffect(e:GetHandler())
		e16:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e16:SetCode(EVENT_CHAINING)
		e16:SetRange(LOCATION_FZONE)
		e16:SetOperation(s.fieldadd)
		e16:SetReset(RESET_EVENT|RESETS_STANDARD)
        Duel.RegisterEffect(e16,tp)
		local e17=e16:Clone()
		e17:SetCode(EVENT_CHAIN_NEGATED)
        Duel.RegisterEffect(e17,tp)

        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e12:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e12:SetDescription(aux.Stringid(id,4))
        e12:SetCondition(s.nscon)
        e12:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x580))
        Duel.RegisterEffect(e12,tp)


	end
	e:SetLabel(1)
end

function s.fustormriderfieldfilter(c)
    return c:IsType(TYPE_FIELD) and c:IsSetCard(0x580) and c:IsFaceup()
end
function s.nscon(e)
	return Duel.IsExistingMatchingCard(s.fustormriderfieldfilter,e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil)
end

function s.stormrideraddfilter(c)
    return c:IsMonster() and c:IsSetCard(0x580) and c:IsAbleToHand()
end


function s.fieldadd(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp, id+4)>0 then return end
	if not (re:GetHandler():IsSetCard(0x580) and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)) then return end
	if Duel.IsExistingMatchingCard(s.stormrideraddfilter, tp, LOCATION_DECK, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_CARD, tp, id)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local tc=Duel.SelectMatchingCard(tp, s.stormrideraddfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
        Duel.SendtoHand(tc, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, tc)

		Duel.RegisterFlagEffect(tp, id+4, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end


function s.taggedcard(c)
    return c:GetFlagEffect(id)>0
end

function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsLinkBelow(2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+3)>0 then return end
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) and eg:IsExists(s.cfilter,1,nil,tp)
end

function s.addfieldfilter(c)
    return c:IsType(TYPE_FIELD) and c:IsSetCard(0x580) and c:IsAbleToHand()
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local addfields=Duel.GetMatchingGroup(s.addfieldfilter, tp, LOCATION_DECK, 0, nil)
    if (#addfields>0) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_CARD, tp, id)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local tc=Group.Select(addfields, tp, 1,1, nil)
        Duel.SendtoHand(tc, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, tc)

        Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
    end
end



function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.taggedcard, tp, LOCATION_ALL, LOCATION_ALL, 1, nil) and Duel.GetTurnPlayer()==tp
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)

        local ftrap=Duel.GetMatchingGroup(s.taggedcard, tp, LOCATION_ALL, LOCATION_ALL, nil)
        if #ftrap>0 then
            Duel.Hint(HINT_CARD, tp, id)
            Duel.RemoveCards(ftrap)
        end
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    local faketrap=Duel.CreateToken(1-tp, 03027001)
    Card.RegisterFlagEffect(faketrap, id, 0,0,0)

    Duel.SendtoGrave(faketrap, REASON_RULE)

end

function s.stormridertorevealfilter(c)
   return c:IsMonster() and c:IsSetCard(0x580) and not c:IsPublic()
end

function s.shufflefieldfilter(c)
    return c:IsType(TYPE_FIELD) and c:IsSetCard(0x580) and c:IsAbleToDeck()
end

function s.shufflemonsterfilter(c)
    return c:IsMonster() and c:IsSetCard(0x580) and c:IsAbleToDeck()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
    local fields=Duel.GetMatchingGroup(s.shufflefieldfilter, tp, LOCATION_GRAVE, 0, nil)
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.stormridertorevealfilter,tp,LOCATION_HAND,0,2,nil)
						and Duel.GetLocationCount(1-tp, LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
        and (not Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE, 0, 1, nil))
            and (#fields>0)
			and Duel.IsExistingMatchingCard(s.shufflemonsterfilter,tp,LOCATION_GRAVE,0,#fields,nil)
            and Duel.IsPlayerCanDraw(tp)


	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

    local fields=Duel.GetMatchingGroup(s.shufflefieldfilter, tp, LOCATION_GRAVE, 0, nil)
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.stormridertorevealfilter,tp,LOCATION_HAND,0,2,nil)
						and Duel.GetLocationCount(1-tp, LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
        and (not Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_MZONE, 0, 1, nil))
            and (#fields>0)
			and Duel.IsExistingMatchingCard(s.shufflemonsterfilter,tp,LOCATION_GRAVE,0,#fields,nil)
            and Duel.IsPlayerCanDraw(tp)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)},
								  {b2,aux.Stringid(id,3)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp, s.stormridertorevealfilter, tp, LOCATION_HAND, 0, 2,2,false,nil)
    Duel.ConfirmCards(1-tp, g)
    local imperm=Duel.CreateToken(1-tp, 10045474)
    Duel.SSet(tp, imperm, 1-tp)


	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    local fields=Duel.GetMatchingGroup(s.shufflefieldfilter, tp, LOCATION_GRAVE, 0, nil)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp, s.shufflemonsterfilter, tp, LOCATION_GRAVE, 0, #fields, #fields, false,nil)
    Group.Merge(g, fields)
    Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_RULE)
    
    Duel.Draw(tp, 1, REASON_RULE)


	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
