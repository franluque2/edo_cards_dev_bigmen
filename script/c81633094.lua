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


        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon3)
		e1:SetOperation(s.flipop3)
		Duel.RegisterEffect(e1,tp)


        --add conscript effects here


	end
	e:SetLabel(1)
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


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp, id+3)>0 and Duel.GetFlagEffect(tp, id+5)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.revchairfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.putontopseraphfilter,tp,LOCATION_DECK,0,1,nil)
		
	local b2=Duel.GetFlagEffect(tp,id+3)==0
	and Duel.IsExistingMatchingCard(s.resetbariancardfilter,tp,LOCATION_HAND,0,1,nil)
	and Duel.IsExistingMatchingCard(s.addstarseraphfilter,tp,LOCATION_DECK,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+5)==0
	and Duel.IsExistingMatchingCard(s.shufflebackchairfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
	and Duel.IsPlayerCanDraw(tp,3)




--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.revchairfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.putontopseraphfilter,tp,LOCATION_DECK,0,1,nil)
		
	local b2=Duel.GetFlagEffect(tp,id+3)==0
	and Duel.IsExistingMatchingCard(s.resetbariancardfilter,tp,LOCATION_HAND,0,1,nil)
	and Duel.IsExistingMatchingCard(s.addstarseraphfilter,tp,LOCATION_DECK,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+5)==0
	and Duel.IsExistingMatchingCard(s.shufflebackchairfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
	and Duel.IsPlayerCanDraw(tp,3)



--copy the bxs from above
local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
									  {b2,aux.Stringid(id,2)},
									  {b3,aux.Stringid(id,3)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	else if op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	else
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end
		
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end


function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    

	Duel.RegisterFlagEffect(tp,id+5,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetFlagEffect(tp, id+2)==0 and Duel.GetTurnCount()~=1 and Duel.GetTurnPlayer()==tp
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_CARD,tp,id)

        local seventhone=Duel.CreateToken(tp, 57734012)
        Duel.SendtoDeck(seventhone, tp, SEQ_DECKTOP, REASON_RULE)

        Duel.RegisterFlagEffect(ep,id+2,0,0,0)


    end
end


