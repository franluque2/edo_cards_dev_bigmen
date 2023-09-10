--Diablo Army
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

        local c=e:GetHandler()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCondition(s.sscon)
		e2:SetOperation(s.ssop)
		Duel.RegisterEffect(e2,tp)


	end
	e:SetLabel(1)
end

function s.canbanishmindfilter(c)
    return c:IsCode(40155554) and c:IsAbleToRemoveAsCost()
end

function s.cansummonsalvofilter(c,e,tp)
    return c:IsCode(59482302) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP_DEFENSE)
end

function s.sscon(e,tp,eg,ep,ev,re,r,rp)

	local b1= Duel.IsExistingMatchingCard(s.canbanishmindfilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.cansummonsalvofilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)


	return (b1)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
        if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.Hint(HINT_CARD,tp,id)
            local g=Duel.GetMatchingGroup(s.cansummonsalvofilter, tp, LOCATION_GRAVE, 0, nil, e, tp)
            local banishtarget=Duel.GetFirstMatchingCard(s.canbanishmindfilter, tp, LOCATION_GRAVE, 0, nil)
            Duel.Remove(banishtarget, POS_FACEUP, REASON_COST)
            local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=1 end

            local num=#g
            if num>ft1 then num=ft1 end
            local tc=g:Select(tp, num, num,nil)
            if tc then
                Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP_DEFENSE)

                for tc1 in tc:Iter() do
                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetDescription(3313)
                    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    tc1:RegisterEffect(e1)
                end
            end
        end
end



function s.tributesalvofilter(c)
    return c:IsCode(59482302) and c:IsReleasableByEffect()
end

function s.spsummonallyfilter(c,e,tp)
    return c:IsSetCard(SET_ALLY_OF_JUSTICE) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, true, false, POS_FACEUP)
end

function s.discardmindfilter(c)
    return c:IsCode(40155554) and c:IsDiscardable(REASON_COST)
end

function s.addaojfilter(c)
    return c:IsSetCard(SET_ALLY_OF_JUSTICE) and c:IsAbleToHand()
end

function s.fuaojsynchrofilter(c)
    return c:IsSetCard(SET_ALLY_OF_JUSTICE) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end

function s.settransplantfilter(c)
    return c:IsCode(56769674) and c:IsSSetable()
end

function s.futransplantfilter(c)
    return c:IsCode(56769674) and c:IsFaceup()
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
    local allysalvo1=Duel.CreateToken(tp, 59482302)
    local allysalvo2=Duel.CreateToken(tp, 59482302)
    Duel.SendtoGrave(allysalvo1, REASON_RULE)
    Duel.SendtoGrave(allysalvo2, REASON_RULE)

    local allymind1=Duel.CreateToken(tp, 40155554)
    local allymind2=Duel.CreateToken(tp, 40155554)
    Duel.SendtoGrave(allymind1, REASON_RULE)
    Duel.SendtoGrave(allymind2, REASON_RULE)



end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.tributesalvofilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.spsummonallyfilter,tp,LOCATION_HAND,0,1,nil,e,tp)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.discardmindfilter,tp,LOCATION_HAND,0,1,nil)
            and Duel.IsExistingMatchingCard(s.addaojfilter,tp,LOCATION_DECK,0,1,nil)

    local b3=Duel.GetFlagEffect(tp,id+3)==0
        and Duel.IsExistingMatchingCard(s.fuaojsynchrofilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.settransplantfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
        and not Duel.IsExistingMatchingCard(s.futransplantfilter,tp,LOCATION_ONFIELD,0,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

    local b1=Duel.GetFlagEffect(tp,id+1)==0
        and Duel.IsExistingMatchingCard(s.tributesalvofilter,tp,LOCATION_ONFIELD,0,1,nil)
                and Duel.IsExistingMatchingCard(s.spsummonallyfilter,tp,LOCATION_HAND,0,1,nil,e,tp)

    local b2=Duel.GetFlagEffect(tp,id+2)==0
        and Duel.IsExistingMatchingCard(s.discardmindfilter,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.addaojfilter,tp,LOCATION_DECK,0,1,nil)

    local b3=Duel.GetFlagEffect(tp,id+3)==0
        and Duel.IsExistingMatchingCard(s.fuaojsynchrofilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.settransplantfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
        and not Duel.IsExistingMatchingCard(s.futransplantfilter,tp,LOCATION_ONFIELD,0,1,nil)



--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)},
								  {b2,aux.Stringid(id,3)},
								  {b3,aux.Stringid(id,4)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

    local g=Duel.GetMatchingGroup(s.spsummonallyfilter, tp, LOCATION_HAND, 0, nil,e,tp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local tribg=Duel.SelectMatchingCard(tp, s.tributesalvofilter, tp, LOCATION_MZONE, 0, 1,#g,false,nil)
    if Duel.Release(tribg, REASON_COST) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sum=g:Select(tp, #tribg, #tribg)
        Duel.SpecialSummon(sum, SUMMON_TYPE_SPECIAL, tp, tp, true, false,POS_FACEUP)
    end



	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    Duel.DiscardHand(tp,s.discardmindfilter, 1,1, REASON_COST, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local tar=Duel.SelectMatchingCard(tp, s.addaojfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
    if tar and Duel.SendtoHand(tar, tp,REASON_RULE) then
        Duel.ConfirmCards(1-tp, tar)
    end

	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    local transp=Duel.SelectMatchingCard(tp, s.settransplantfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1,1,false,nil)
    Duel.SSet(tp, transp)
    Duel.ConfirmCards(1-tp, transp)


	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

