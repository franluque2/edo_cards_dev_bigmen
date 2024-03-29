--Order Up!
--Duel.LoadScript("big_aux.lua")


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


        
		local c=e:GetHandler()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCountLimit(1)
		e6:SetCode(EVENT_PHASE+PHASE_END)
		e6:SetCondition(s.adcon2)
		e6:SetOperation(s.adop2)
		Duel.RegisterEffect(e6,tp)


	end
	e:SetLabel(1)
end

function s.ccuisinefilter(c)
    return c:IsCode(511001087) and c:IsSSetable()
end

function s.fcemfilter(c)
    return c:IsCode(511001086) and c:IsFaceup()
end

function s.adcon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.fcemfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
            and Duel.IsExistingMatchingCard(s.ccuisinefilter, tp, LOCATION_GRAVE+LOCATION_DECK, 0, 1, nil)
    end
    
    function s.adop2(e,tp,eg,ep,ev,re,r,rp)
        Duel.Hint(HINT_CARD,tp,id)
        local g=Duel.SelectMatchingCard(tp,s.ccuisinefilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,false,nil)
        if g then
            Duel.SSet(tp, g)
        end
    end

function s.royalcpaladdfilter(c)
	return c:IsSetCard(0x1512) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetTurnPlayer()==tp and not (Duel.GetFlagEffect(tp,id+3)>0) then return end

	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.royalcpaladdfilter,tp,LOCATION_DECK,0,1,nil)


	return Duel.GetTurnPlayer()==tp and (b1)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)	
		local g=Duel.GetMatchingGroup(s.royalcpaladdfilter,tp,LOCATION_DECK,0,nil)
        if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.Hint(HINT_CARD,tp,id)
            local cardnumber=Duel.GetRandomNumber(1, #g )
            local tc=g:GetFirst()
            while tc do
                if cardnumber==1 then
                    Duel.SendtoHand(tc, tp, REASON_EFFECT)
                end
                cardnumber=cardnumber-1
                tc=g:GetNext()
            end
        end
    Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)

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
    local cemetary=Duel.CreateToken(tp, 81632257)
    Duel.SSet(tp, cemetary)

end

function s.regrecipesfilter(c)
    return c:IsCode(511001089) and c:IsFaceup()
end

function s.setrecipesfilter(c)
    return c:IsCode(511001089) and c:IsSSetable()
end

function s.roycpalrevfilter(c)
    return c:IsSetCard(0x1512) and not c:IsPublic()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
            and not Duel.IsExistingMatchingCard(s.regrecipesfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.setrecipesfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
                        and Duel.IsExistingMatchingCard(s.roycpalrevfilter,tp,LOCATION_HAND,0,3,nil)
                        and Duel.GetLocationCount(tp, LOCATION_SZONE)>0



--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
            and not Duel.IsExistingMatchingCard(s.regrecipesfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.setrecipesfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.roycpalrevfilter,tp,LOCATION_HAND,0,3,nil)
            and Duel.GetLocationCount(tp, LOCATION_SZONE)>0


--effect selector
	--local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)})
	--op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	--if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	--end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp, s.roycpalrevfilter, tp, LOCATION_HAND, 0, 3, 3, nil)
    if g then
        Duel.ConfirmCards(1-tp, g)
        local tc = Duel.SelectMatchingCard(tp, s.setrecipesfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil)
        if tc then
            Duel.SSet(tp, tc)
        end
    end
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end
