--Ice Queen of the Barians
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
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PREDRAW)
		e2:SetCondition(s.flipcon3)
		e2:SetOperation(s.flipop3)
		Duel.RegisterEffect(e2,tp)


		local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_RACE)
        e5:SetTargetRange(LOCATION_DECK,0)
        e5:SetTarget(function(_,c)  return c:IsOriginalRace(RACE_WINGEDBEAST) end)
        e5:SetValue(RACE_FISH)
        Duel.RegisterEffect(e5,tp)

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


function s.discon(e)
	return Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()
end

function s.actfilter(e,c)
	return c:IsType(TYPE_XYZ)
end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.xyzop(_,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end


function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    local btopia=Duel.CreateToken(tp, 30761649)
    Duel.ActivateFieldSpell(btopia,e,tp,eg,ep,ev,re,r,rp)

    local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_EXTRA,0,nil,13183454)

    local tc=g:GetFirst()
    while tc do
        Xyz.AddProcedure(tc,s.xyzop,5,2)
        tc=g:GetNext()
    end

    g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_EXTRA,0,nil,86848580)

    tc=g:GetFirst()
    while tc do
        Xyz.AddProcedure(tc,s.xyzop,4,2)
        tc=g:GetNext()
    end

end

function s.revblizzbirbfilter(c)
	return c:IsCode(50920465) and not c:IsPublic()
end

function s.sendwingedbeastfilter(c)
	return c:IsMonster() and c:IsRace(RACE_WINGEDBEAST) and c:IsAbleToGrave()
end

function s.addaurorawingfilter(c)
	return c:IsCode(70089580) and c:IsAbleToHand()
end

function s.revsirenocafilter(c)
	return c:IsCode(50074392) and not c:IsPublic()
end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp, id+3)>0 and Duel.GetFlagEffect(tp, id+5)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.revblizzbirbfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.addaurorawingfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.sendwingedbeastfilter,tp,LOCATION_DECK,0,1,nil)
		
	local b3=Duel.GetFlagEffect(tp,id+5)==0
	and Duel.GetMatchingGroupCount(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)>0
	and Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, nil)>1
	and Duel.IsExistingMatchingCard(s.revsirenocafilter,tp,LOCATION_HAND,0,1,nil)




--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.revblizzbirbfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.addaurorawingfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.sendwingedbeastfilter,tp,LOCATION_DECK,0,1,nil)
		
	local b3=Duel.GetFlagEffect(tp,id+5)==0
	and Duel.GetMatchingGroupCount(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)>0
	and Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, nil)>1
	and Duel.IsExistingMatchingCard(s.revsirenocafilter,tp,LOCATION_HAND,0,1,nil)



--copy the bxs from above
local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
									  {b3,aux.Stringid(id,4)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	else if op==1 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end
		
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local rev=Duel.SelectMatchingCard(tp, s.revblizzbirbfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
	if rev then
		Duel.ConfirmCards(1-tp, rev)

	
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local tosend=Duel.SelectMatchingCard(tp, s.sendwingedbeastfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
	if tosend and Duel.SendtoGrave(tosend, REASON_RULE) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local tohand=Duel.SelectMatchingCard(tp, s.addaurorawingfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
		if tohand and Duel.SendtoHand(tohand, tp, REASON_RULE) then
			Duel.ConfirmCards(1-tp, tohand)
		end
	
	end

	end
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end


function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local rev=Duel.SelectMatchingCard(tp, s.revsirenocafilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
	if rev then
		Duel.ConfirmCards(1-tp, rev)

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
		local rc=Duel.AnnounceRace(tp,1,RACE_WINGEDBEAST|RACE_FISH)


		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
		local tc=Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()


			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(rc)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)

	end
    

	Duel.RegisterFlagEffect(tp,id+5,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetFlagEffect(tp, id+2)==0 and Duel.GetTurnCount()~=1 and Duel.GetTurnPlayer()==tp and Duel.GetLP(tp)<=2000
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 5)) then
        Duel.Hint(HINT_CARD,tp,id)

        local seventhone=Duel.CreateToken(tp, 57734012)
        Duel.SendtoDeck(seventhone, tp, SEQ_DECKTOP, REASON_RULE)

        Duel.RegisterFlagEffect(ep,id+2,0,0,0)


    end
end


