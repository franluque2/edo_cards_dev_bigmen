--Mayor of Heartland City
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

function s.archetypefilter(c)
    return c:IsType(TYPE_XYZ)
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

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(s.repcon)
		e2:SetOperation(s.repop)
		Duel.RegisterEffect(e2,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_TO_HAND)
		e3:SetCondition(s.repcon)
		e3:SetOperation(s.repop2)
		Duel.RegisterEffect(e3,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_PREDRAW)
		e8:SetCondition(s.addcon)
		e8:SetOperation(s.addop)
		Duel.RegisterEffect(e8,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetTargetRange(0,LOCATION_MZONE)
        e7:SetCondition(s.immcon)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)

        --add conscriptions effects here

        --XYZ Monsters in Possession become "Heart Monsters"
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(0x528)
        Duel.RegisterEffect(e5,tp)

        --All Monsters in Possession become DARK Insect "Steelswarm" "Amorphage" monsters
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_ATTRIBUTE)
        e6:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e6:SetValue(ATTRIBUTE_DARK)
        Duel.RegisterEffect(e6,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_ADD_RACE)
        e9:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e9:SetValue(RACE_INSECT)
        Duel.RegisterEffect(e9,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
        e10:SetType(EFFECT_TYPE_FIELD)
        e10:SetCode(EFFECT_ADD_SETCODE)
        e10:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e10:SetTarget(function(_,c)  return c:IsMonster() end)
        e10:SetValue(0x100a)
        Duel.RegisterEffect(e10,tp)

        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_ADD_SETCODE)
        e11:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e11:SetTarget(function(_,c)  return c:IsMonster() end)
        e11:SetValue(0xe0)
        Duel.RegisterEffect(e11,tp)

        --All monsters you control and in GY become WATER monsters
        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_ADD_ATTRIBUTE)
        e12:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,0)
        e12:SetValue(ATTRIBUTE_WATER)
        Duel.RegisterEffect(e12,tp)

        --monsters you control become "Infection Fly"
        local e13=Effect.CreateEffect(e:GetHandler())
        e13:SetType(EFFECT_TYPE_FIELD)
        e13:SetCode(EFFECT_CHANGE_CODE)
        e13:SetTargetRange(LOCATION_MZONE,0)
        e13:SetValue(511002468)
        Duel.RegisterEffect(e13,tp)

        
        --All monsters in Deck become "Heart Monsters"
        local e14=Effect.CreateEffect(e:GetHandler())
        e14:SetType(EFFECT_TYPE_FIELD)
        e14:SetCode(EFFECT_ADD_SETCODE)
        e14:SetTargetRange(LOCATION_DECK,0)
        e14:SetValue(0x528)
        Duel.RegisterEffect(e14,tp)

        -- can only activate number 2 once per turn

        local e16=Effect.CreateEffect(e:GetHandler())
		e16:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e16:SetCode(EVENT_CHAINING)
		e16:SetRange(LOCATION_MZONE)
		e16:SetOperation(s.aclimit)
		e16:SetReset(RESET_EVENT|RESETS_STANDARD)
        Duel.RegisterEffect(e16,tp)
		local e17=e16:Clone()
		e17:SetCode(EVENT_CHAIN_NEGATED)
        Duel.RegisterEffect(e17,tp)

        local e18=Effect.CreateEffect(e:GetHandler())
        e18:SetType(EFFECT_TYPE_FIELD)
        e18:SetCode(EFFECT_CANNOT_TRIGGER)
        e18:SetTargetRange(LOCATION_MZONE,0)
        e18:SetCondition(s.discon2)
        e18:SetTarget(s.actfilter2)
        Duel.RegisterEffect(e18, tp)

        --cannot activate cicada king and mosquito on opps turn
        local e15=Effect.CreateEffect(e:GetHandler())
        e15:SetType(EFFECT_TYPE_FIELD)
        e15:SetCode(EFFECT_CANNOT_TRIGGER)
        e15:SetTargetRange(LOCATION_MZONE,0)
        e15:SetCondition(s.discon)
        e15:SetTarget(s.actfilter)
        Duel.RegisterEffect(e15, tp)




	end
	e:SetLabel(1)
end

function s.aclimit(e,tp,eg,ep,ev,re,r,rp)
	if not re:GetHandler():IsCode(32453837) then return end
	if e:GetCode()==EVENT_CHAINING then
		Duel.RegisterFlagEffect(tp, id+4, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	else
		Duel.ResetFlagEffect(tp, id+4)
	end
end

function s.discon2(e)
	return (Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()) and Duel.GetFlagEffect(e:GetHandlerPlayer(), id+4)>0
end

function s.actfilter2(e,c)
	return c:IsCode(32453837)
end


function s.discon(e)
	return Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()
end

function s.actfilter(e,c)
	return c:IsCode(32453837, 04997565)
end

function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.efilter(e,te)
	return te:GetHandler():IsOriginalCode(04997565,67557908)
end


function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+3)==0
         and Duel.GetDrawCount(tp)>0 and Duel.IsExistingMatchingCard(s.infectionflyaddfilter, tp, LOCATION_DECK, 0, 1, nil)
         and Duel.GetTurnCount()>1
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
        Duel.Hint(HINT_CARD,tp,id)
        local dt=Duel.GetDrawCount(tp)
        if dt~=0 then
            _replace_count=0
            _replace_max=dt
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetCode(EFFECT_DRAW_COUNT)
            e1:SetTargetRange(1,0)
            e1:SetReset(RESET_PHASE+PHASE_DRAW)
            e1:SetValue(0)
            Duel.RegisterEffect(e1,tp)
        end
        
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local card=Duel.GetFirstMatchingCard(s.infectionflyaddfilter, tp, LOCATION_DECK, 0, nil)
        Duel.SendtoHand(card, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, card)
    end
	Duel.RegisterFlagEffect(ep,id+3,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.validreplacefilter(c)
    return c:IsAbleToDeck() and (not c:IsOriginalCode(511002468)) and c:IsPreviousLocation(LOCATION_DECK) and c:IsMonster() and not c:IsReason(REASON_DRAW)
end



function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.validreplacefilter, 1, nil) and rp==tp
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=eg:Filter(s.validreplacefilter, nil)
    if #eg>0 and Duel.IsExistingMatchingCard(s.infectionflyspfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp, POS_FACEUP) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
    Duel.Hint(HINT_CARD,tp,id)
    local tc=g:GetFirst()
    while tc do
        if Duel.IsExistingMatchingCard(s.infectionflyspfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp, tc:GetPosition()) then
            local pos=tc:GetPosition()
            Duel.SendtoDeck(tc, tp, SEQ_DECKSHUFFLE, REASON_RULE)
            local fly=Duel.GetFirstMatchingCard(s.infectionflyspfilter, tp, LOCATION_DECK, 0, nil, e, tp, pos)
            Duel.SpecialSummon(fly, SUMMON_TYPE_SPECIAL, tp, tp, false, false, pos)
        end
        tc=g:GetNext()
    end
    end
end

function s.repop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=eg:Filter(s.validreplacefilter, nil)
    if #eg>0 and Duel.IsExistingMatchingCard(s.infectionflyaddfilter, tp, LOCATION_DECK, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
    Duel.Hint(HINT_CARD,tp,id)
    local tc=g:GetFirst()
    while tc do
        if Duel.IsExistingMatchingCard(s.infectionflyaddfilter, tp, LOCATION_DECK, 0, 1, nil) then
            Duel.SendtoDeck(tc, tp, SEQ_DECKSHUFFLE, REASON_RULE)
            local fly=Duel.GetFirstMatchingCard(s.infectionflyaddfilter, tp, LOCATION_DECK, 0, nil)
            Duel.SendtoHand(fly, tp, REASON_RULE)
        end
        tc=g:GetNext()
    end
    end
end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

    local g=Duel.GetMatchingGroup(s.archetypefilter, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.isinfectionfly(c)
    return c:IsCode(511002468)
end

function s.infectionflyaddfilter(c)
    return s.isinfectionfly(c) and c:IsAbleToHand()
end

function s.infectionflyspfilter(c,e,tp,pos)
    return s.isinfectionfly(c) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false, pos)
end

function s.infectionflyrevealfilter(c)
    return s.isinfectionfly(c) and not c:IsPublic()
end

function s.multiflyfilter(c)
    return c:IsCode(511002469) and c:IsSSetable()
end

function s.isfuinfectionfly(c)
    return s.isinfectionfly(c) and c:IsFaceup()
end

function s.isfuoginfectionfly(c)
    return c:IsOriginalCode(511002468) and c:IsFaceup()
end
--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.isfuinfectionfly,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.infectionflyrevealfilter,tp,LOCATION_HAND,0,2,nil)
                        and Duel.IsExistingMatchingCard(s.multiflyfilter,tp,LOCATION_DECK,0,1,nil)
						and Duel.GetLocationCount(tp, LOCATION_SZONE)>0


	local b2=Duel.GetFlagEffect(tp,id+2)==0
        and Duel.IsExistingMatchingCard(s.isfuoginfectionfly,tp,LOCATION_ONFIELD,0,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above
local b1=Duel.GetFlagEffect(tp,id+1)==0
    and Duel.IsExistingMatchingCard(s.isfuinfectionfly,tp,LOCATION_ONFIELD,0,1,nil)
                and Duel.IsExistingMatchingCard(s.infectionflyrevealfilter,tp,LOCATION_HAND,0,2,nil)
                and Duel.IsExistingMatchingCard(s.multiflyfilter,tp,LOCATION_DECK,0,1,nil)
                and Duel.GetLocationCount(tp, LOCATION_SZONE)>0


local b2=Duel.GetFlagEffect(tp,id+2)==0
    and Duel.IsExistingMatchingCard(s.isfuoginfectionfly,tp,LOCATION_ONFIELD,0,1,nil)
--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp, s.infectionflyrevealfilter, tp, LOCATION_HAND, 0, 2, 2, false,nil)
    if tc then
        Duel.ConfirmCards(1-tp, tc)

        local mul=Duel.GetFirstMatchingCard(s.multiflyfilter, tp, LOCATION_DECK, 0, nil)
        if mul then
            Duel.SSet(tp, mul)
            Duel.ConfirmCards(1-tp, mul)
        end
    end
--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.haslevelfilter(c)
    return c:IsFaceup() and c:HasLevel() and c:IsLevelBelow(4)
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,3)

    local g=Duel.GetMatchingGroup(s.haslevelfilter, tp, LOCATION_MZONE, 0, nil)

    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
        
    end




	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end