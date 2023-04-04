--The☆Skill of Terror
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
		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local c=e:GetHandler()
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCountLimit(1)
        e2:SetCode(EVENT_PHASE+PHASE_END)
        e2:SetCondition(s.setcon)
        e2:SetOperation(s.setop)
        Duel.RegisterEffect(e2,tp)

        local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e4:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
		e4:SetTarget(aux.TargetBoolFunction(s.thedragiastarfilter,tp))
		e4:SetValue(s.efilter2)
		Duel.RegisterEffect(e4,tp)

	end
	e:SetLabel(1)
end

function s.efilter2(e,re,tp)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end


function s.thedragiastarfilter(c,tp)
	return c:IsCode(160012035) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.thedragiasfilter,tp,LOCATION_ONFIELD,0,2,nil)
end


function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.thedragiasfilter,tp,LOCATION_ONFIELD,0,2,nil) and
        Duel.IsExistingMatchingCard(s.thestarfilterset, tp, LOCATION_GRAVE, 0, 1, nil) and Duel.GetLocationCount(tp, LOCATION_SZONE-LOCATION_FZONE)>0
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)

    if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
        Duel.Hint(HINT_CARD,tp,id)

        local tar=Duel.SelectMatchingCard(tp, s.thestarfilterset, tp, LOCATION_GRAVE, 0, 1,1,false,nil)
        if tar then
            Duel.SSet(tp, tar)
            Duel.ConfirmCards(1-tp, tar)

            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(3300)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            tar:GetFirst():RegisterEffect(e1,true)
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

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    local ddoom=Duel.CreateToken(tp, 160012060)
    Duel.SendtoGrave(ddoom, REASON_RULE)

end

function s.thestarfilter(c)
    return c:IsCode(81632330,81632331, 160012046, 160012047, 160204027, 160204028)
end

function s.thestarfilteradd(c)
    return s.thestarfilter(c) and c:IsSpellTrap() and c:IsAbleToHand()
end

function s.senddragonfilterdeck(c,code)
    return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL) and c:IsCode(code) and c:IsAbleToGrave()
end

function s.senddragonfilterhand(c)
    return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL) and
         c:IsAbleToGrave() and Duel.IsExistingMatchingCard(s.senddragonfilterdeck, c:GetOwner(), LOCATION_DECK, 0, 1, nil, c:Code())
end

function s.viceslasherfilter(c)
    return c:IsCode(160012048) and c:IsSSetable()
end

function s.thestarfilterset(c)
    return s.thestarfilter(c) and c:IsTrap() and c:IsSSetable()
end

function s.thedragiasfilter(c)
    return c:IsFaceup() and c:IsCode(160012003)
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.senddragonfilterhand,tp,LOCATION_HAND,0,1,nil)
						and Duel.IsExistingMatchingCard(s.thestarfilteradd,tp,LOCATION_DECK,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.thedragiasfilter,tp,LOCATION_ONFIELD,0,2,nil)
            and Duel.IsExistingMatchingCard(s.viceslasherfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.GetLocationCount(tp, LOCATION_SZONE-LOCATION_FZONE)>0


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
and Duel.IsExistingMatchingCard(s.senddragonfilterhand,tp,LOCATION_HAND,0,1,nil)
            and Duel.IsExistingMatchingCard(s.thestarfilteradd,tp,LOCATION_DECK,0,1,nil)

local b2=Duel.GetFlagEffect(tp,id+2)==0
    and Duel.IsExistingMatchingCard(s.thedragiasfilter,tp,LOCATION_ONFIELD,0,2,nil)
    and Duel.IsExistingMatchingCard(s.viceslasherfilter,tp,LOCATION_DECK,0,1,nil)
    and Duel.GetLocationCount(tp, LOCATION_SZONE-LOCATION_FZONE)>0

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

    local tar=Duel.SelectMatchingCard(tp, s.senddragonfilterhand, tp, LOCATION_HAND, 0, 1,1,false,nil):GetFirst()
    if tar then
        local tar2=Duel.SelectMatchingCard(tp, s.senddragonfilterdeck, tp, LOCATION_DECK, 0, 1,1,false,nil, tar:Code()):GetFirst()

        local group=Group.CreateGroup()
        group:AddCard(tar)
        group:AddCard(tar2)

        if Duel.SendtoGrave(group, REASON_RULE) then
            local st=Duel.SelectMatchingCard(tp, s.thestarfilteradd, tp, LOCATION_DECK, 0, 1,1,false,nil)
            if st then
                Duel.SendtoHand(st, tp, REASON_EFFECT)
                Duel.ConfirmCards(1-tp, st)
            end
        end
    end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

    local vslasher=Duel.GetFirstMatchingCard(s.viceslasherfilter, tp, LOCATION_DECK, 0, nil)
    if vslasher then
        Duel.SSet(tp, vslasher)
    end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
