--Pattern of Command
Duel.LoadScript("big_aux.lua")


local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_STARTUP)
    e0:SetCountLimit(1)
    e0:SetRange(0x5f)
    e0:SetOperation(s.flipopextra)
    c:RegisterEffect(e0)

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

function s.lightcybersefilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_CYBERSE)
end

function s.mentionsarmatosfilter(c)
    return c:IsSpellTrap() and (Card.ListsArchetype(c,0x578) or c:IsCode(511030029))
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_ADD_SETCODE)
        e3:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e3:SetTarget(aux.TargetBoolFunction(s.lightcybersefilter))
        e3:SetValue(0x578)
        Duel.RegisterEffect(e3,tp)

        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_ADD_SETCODE)
        e4:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e4:SetTarget(aux.TargetBoolFunction(s.mentionsarmatosfilter))
        e4:SetValue(0x136)
        Duel.RegisterEffect(e4,tp)

        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCondition(s.epcon)
		e5:SetOperation(s.epop)
        e5:SetCountLimit(1)
		Duel.RegisterEffect(e5,tp)


        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAINING)
		e2:SetCondition(s.discon)
		e2:SetOperation(s.disop)
		Duel.RegisterEffect(e2,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_CANNOT_TRIGGER)
        e7:SetTargetRange(LOCATION_SZONE,0)
        e7:SetCondition(s.discon2)
        e7:SetTarget(s.actfilter)
        Duel.RegisterEffect(e7, tp)


        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_DISABLE)
        e6:SetTargetRange(LOCATION_MZONE,0)
        e6:SetTarget(aux.TargetBoolFunction(s.magnusfilter))
        Duel.RegisterEffect(e6, tp)


        local e12=Effect.CreateEffect(e:GetHandler())
		e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e12:SetCode(EVENT_CHAINING)
		e12:SetCondition(s.discon4)
		e12:SetOperation(s.disop2)
		Duel.RegisterEffect(e12,tp)

        local e17=Effect.CreateEffect(e:GetHandler())
        e17:SetType(EFFECT_TYPE_FIELD)
        e17:SetCode(EFFECT_CANNOT_TRIGGER)
        e17:SetTargetRange(LOCATION_MZONE,0)
        e17:SetCondition(s.discon3)
        e17:SetTarget(s.actfilter2)
        Duel.RegisterEffect(e17, tp)

        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD)
        e11:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
        e11:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e11:SetTargetRange(0,1)
        e11:SetValue(s.damval)
        Duel.RegisterEffect(e11,tp)

	end
	e:SetLabel(1)
end

function s.linkedarrowfilter(c,tc)
    return c:IsFaceup() and c:IsCode(511009503) and c:GetLinkedGroup():IsContains(tc)
end

function s.isanarrowcontaining(c,tp)
    return Duel.IsExistingMatchingCard(s.linkedarrowfilter, tp, LOCATION_SZONE, 0, 1, nil,c)
end

function s.damval(e,rc)
	if not ((rc:GetLinkedGroup():FilterCount(Card.IsCode,nil,511009503)>0) or s.isanarrowcontaining(rc,e:GetHandlerPlayer())) then return -1 end
	return HALF_DAMAGE
end

function s.magnusfilter(c)
    return c:IsCode(511030028) and c:GetMutualLinkedGroup():FilterCount(Card.IsLinkSpell,nil)==0
end

function s.discon3(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+2)>0
end

function s.actfilter2(e,c)
	return c:IsCode(511030018)
end

function s.discon4(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(511030018) and (Duel.GetFlagEffect(tp,id+2)==0)
end

function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end



function s.discon2(e)
    local ph=Duel.GetCurrentPhase()

	return  Duel.IsBattlePhase() and Duel.GetFlagEffect(e:GetHandlerPlayer(),id+1)>0
end

function s.actfilter(e,c)
	return c:IsCode(511030021)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()

	return re:IsActiveType(TYPE_SPELL)
		and re:GetHandler():IsCode(511030021) and (Duel.GetFlagEffect(tp,id+1)==0)
        and Duel.IsBattlePhase()
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.highlevelarmatosfilter(c)
    return c:IsSetCard(0x136) and c:IsLinkAbove(4)
end

function s.fugloriafilter(c)
    return c:IsCode(511030009) and c:IsFaceup()
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.fugloriafilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)

        local gloria=Duel.GetMatchingGroup(s.fugloriafilter, tp, LOCATION_ONFIELD, 0, nil)
        if #gloria>0 and not Duel.IsExistingMatchingCard(s.highlevelarmatosfilter, tp, LOCATION_MZONE, 0, 1, nil) then
            Duel.Hint(HINT_CARD,tp,id)
            Duel.SendtoGrave(gloria, REASON_RULE)

        end
end




function s.flipopextra(e,tp,eg,ep,ev,re,r,rp)
	local arrows=Duel.GetFirstMatchingCard(Card.IsCode, tp, LOCATION_DECK, 0, nil, 511009503)

    Duel.DisableShuffleCheck()

	if arrows then
		Duel.MoveSequence(arrows,0)
	end

    Duel.DisableShuffleCheck(false)

end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end



function s.sendarmatosfilter(c)
    return c:IsSetCard(0x578) and c:IsMonster() and c:IsAbleToGraveAsCost()
end

function s.summonoraddarmatosfilter(c,e,tp)
    return c:IsSetCard(0x578) and c:IsMonster() and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false, POS_FACEUP))
end

function s.banisharmatosfilter(c)
    return c:IsSetCard(0x578) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end

function s.setfieldfilter(c)
    return c:IsCode(511030025) and c:IsSSetable()
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0  then return end
	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.sendarmatosfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,nil)
						and Duel.IsExistingMatchingCard(s.summonoraddarmatosfilter,tp,LOCATION_DECK,0,1,nil,e,tp)

	local b2=Duel.GetFlagEffect(tp,id+4)==0
			and Duel.IsExistingMatchingCard(s.banisharmatosfilter,tp,LOCATION_GRAVE,0,2,nil)
            and (not Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_FZONE, 0, 1, nil))
            and Duel.IsExistingMatchingCard(s.setfieldfilter,tp,LOCATION_GRAVE,0,1,nil)


	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)


	local b1=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.sendarmatosfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,nil)
						and Duel.IsExistingMatchingCard(s.summonoraddarmatosfilter,tp,LOCATION_DECK,0,1,nil,e,tp)

	local b2=Duel.GetFlagEffect(tp,id+4)==0
			and Duel.IsExistingMatchingCard(s.banisharmatosfilter,tp,LOCATION_GRAVE,0,2,nil)
            and (not Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_FZONE, 0, 1, nil))
            and Duel.IsExistingMatchingCard(s.setfieldfilter,tp,LOCATION_GRAVE,0,1,nil)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,2)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local send=Duel.SelectMatchingCard(tp, s.sendarmatosfilter, tp, LOCATION_MZONE|LOCATION_HAND, 0, 1,1,false,nil)
    if send and Duel.SendtoGrave(send, REASON_COST) then
        local toaddsum=Duel.SelectMatchingCard(tp, s.summonoraddarmatosfilter, tp, LOCATION_DECK, 0, 1,1,false,nil,e,tp)
        if toaddsum then
            if Card.IsAbleToHand(toaddsum:GetFirst()) and (not toaddsum:GetFirst():IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false, POS_FACEUP)) or not Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
                Duel.SendtoHand(toaddsum, tp, REASON_RULE)
                Duel.ConfirmCards(1-tp, toaddsum)
            else
                Duel.SpecialSummon(toaddsum, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
            end
        end
    end


	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end

function s.thfilter(c)
	return c:IsSetCard(0x578) and c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)

    local tc=Duel.SelectMatchingCard(tp, s.setfieldfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil)
    if tc then
        Duel.SSet(tp, tc)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3300)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		tc:GetFirst():RegisterEffect(e2)
    end

	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
end
