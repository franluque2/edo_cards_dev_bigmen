--Signing a Forbidden Covenant
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


        --stage 1-----------------------------------------------
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)


        --cannot win with effects
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e8:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
        e8:SetTargetRange(0,1)
        e8:SetValue(1)
        e8:SetCondition(s.cantwincon)
        Duel.RegisterEffect(e8,tp)



        --change from stage 1 to stage 2
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_CONTINUOUS)
        e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e2:SetCode(EVENT_ADJUST)
        e2:SetCondition(s.changestage2con)
        e2:SetOperation(s.changestage2op)
        Duel.RegisterEffect(e2,tp)

        -- change from stage 2 to stage 3

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
        e3:SetCode(EVENT_LEAVE_FIELD)
        e3:SetCountLimit(1)
        e3:SetCondition(s.changestage3con)
        e3:SetOperation(s.changestage3op)
        Duel.RegisterEffect(e3,tp)

        ---stage 3 effects----------------

        --double attack of exodius

        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_UPDATE_ATTACK)
        e4:SetTargetRange(LOCATION_MZONE,0)
        e4:SetTarget(function (_,c) return s.exodiusfilter(c) end)
        e4:SetValue(s.atkval)
        e4:SetCondition(s.isstage3con)
        Duel.RegisterEffect(e4,tp)

        --opp takes no dmg from exodius

        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e5:SetTargetRange(LOCATION_MZONE,0)
        e5:SetCondition(s.isstage3con)
		e5:SetTarget(s.rdtg)
		e5:SetValue(0)
		Duel.RegisterEffect(e5,tp)

        -- on draw, send to grave, add to exodius
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e6:SetCode(EVENT_TO_HAND)
        e6:SetCondition(s.isforbiddencon)
        e6:SetOperation(s.sendforbiddencardop)
        Duel.RegisterEffect(e6, tp)

        --always active------

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e7:SetCode(EFFECT_CANNOT_ACTIVATE)
        e7:SetTargetRange(1,0)
        e7:SetValue(s.aclimit)
        Duel.RegisterEffect(e7,tp)

        -- win if all 5 pieces are in GY
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e8:SetProperty(EFFECT_FLAG_DELAY)
        e8:SetCode(EVENT_TO_GRAVE)
        e8:SetCondition(s.wincon)
        e8:SetOperation(s.winop)
        Duel.RegisterEffect(e8, tp)


        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e9:SetProperty(EFFECT_FLAG_DELAY)
        e9:SetCode(EVENT_TO_GRAVE)
        e9:SetCondition(s.tagcon)
        e9:SetOperation(s.tagop)
        Duel.RegisterEffect(e9, tp)

	end
	e:SetLabel(1)
end

function s.sentfilter(c,re)
    local rc
    if re then
        rc=re:GetHandler()
    end
    return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsMonster() and (rc and rc:IsCode(13893596,511000244))
end

function s.tagcon(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.sentfilter, nil, re)
    return #g>0
end

function s.tagop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.sentfilter, nil, re)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD, 0, 0)  
    end
end


function s.flagfilter(c)
    return c:GetFlagEffect(id)>0
end

function s.wincon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.flagfilter, tp, LOCATION_GRAVE, 0, nil,re)
    return (Duel.GetFlagEffect(tp, id+4)>0) and Duel.IsExistingMatchingCard(s.exodiusfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and g:GetClassCount(Card.GetCode)>4
end

function s.winop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,tp,id+2)
    Duel.Win(tp, 0x1680)
end

function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(58604027) and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetLocation()==LOCATION_MZONE
end

function s.winfilter(c,rc)
	return c:IsRelateToCard(rc) and c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsMonster()
end

function s.sendforbiddencardop(e,tp,eg,ep,ev,re,r,rp)
    local forbiddencards=eg:Filter(s.cfilter, nil, tp)
    Duel.SendtoGrave(forbiddencards, REASON_EFFECT)
    for tc in forbiddencards:Iter() do
        tc:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD, 0, 0)
    end
end

function s.rdtg(e,c)
	return c:IsCode(13893596) and c:IsFaceup()
end

function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsSetCard(0x40) and c:IsMonster()
end

function s.isforbiddencon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp) and (Duel.GetFlagEffect(tp, id+4)>0) and Duel.IsExistingMatchingCard(s.exodiusfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.isstage3con(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetFlagEffect(e:GetHandlerPlayer(), id+4)>0)
end

function s.atkval(_,c)
    return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_NORMAL)*1000
end

function s.exodiusfilter(c)
    return c:IsCode(13893596) and c:IsFaceup()
end

function s.necrossfilter(c)
    return (c:IsReason(REASON_DESTROY) or c:GetReasonPlayer()~=c:GetControler()) and c:IsCode(12600382)
end

function s.changestage3con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp, id+2)>0 and Duel.GetFlagEffect(tp, id+4)==0 and eg:IsExists(s.necrossfilter, 1, nil)
end

function s.ritualfilter(c)
    return c:IsCode(511000244) and c:IsAbleToHand()
end
function s.changestage3op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id+1|(1<<32))
    Duel.Hint(HINT_CARD,tp,id+1)

    --disable other parts of the skill
    Duel.RegisterFlagEffect(tp,id+4,0,0,0)

    --create new img
    e:GetHandler():Recreate(id+2)
    Duel.Hint(HINT_SKILL_REMOVE,tp,id)
    Duel.Hint(HINT_SKILL_FLIP,tp,(id+2)|(1<<32))
    Duel.Hint(HINT_SKILL,tp,id+2)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local ritual=Duel.SelectMatchingCard(tp, s.ritualfilter, tp, LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, 1, false, nil)
    if ritual then
        Duel.SendtoHand(ritual, tp, REASON_RULE)
        Duel.ConfirmCards(tp, ritual)
    end

    local exodius=Duel.CreateToken(tp, 13893596)
    Duel.SendtoHand(exodius, tp, REASON_RULE)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,3)
	e1:SetTarget(function(e,c) return not c:IsCode(13893596) end)
	Duel.RegisterEffect(e1,tp)


end

function s.isforbiddenonefilter(c)
    return c:IsSetCard(0x40) and c:IsMonster()
end

function s.changestage2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.isforbiddenonefilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 5, nil) and Duel.GetFlagEffect(tp, id+2)==0
end

function s.changestage2op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)

    local forbiddencards=Duel.GetMatchingGroup(s.isforbiddenonefilter, tp, LOCATION_HAND, 0, nil)
    if forbiddencards then
        Duel.ConfirmCards(1-tp, forbiddencards)
    end
    --disable other parts of the skill
    Duel.RegisterFlagEffect(tp,id+2,0,0,0)

    --create new img
    e:GetHandler():Recreate(id+1)
    Duel.Hint(HINT_SKILL_REMOVE,tp,id)
    Duel.Hint(HINT_SKILL_FLIP,tp,(id+1)|(1<<32))
    Duel.Hint(HINT_SKILL,tp,id+1)

    if forbiddencards then
        Duel.SendtoGrave(forbiddencards, REASON_DISCARD)
        Duel.Draw(tp, #forbiddencards, REASON_RULE)
    end

    local contract=Duel.CreateToken(tp, 33244944)
    Duel.SSet(tp, contract)

    local necross=Duel.CreateToken(tp, 12600382)
    Duel.SendtoHand(necross, tp, REASON_RULE)

end


function s.cantwincon(e)
	return not (Duel.GetFlagEffect(e:GetHandlerPlayer(), id+4)>0)
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


    local legexodia=Duel.CreateToken(tp, 58604027)
    Duel.SpecialSummon(legexodia, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(3206)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    legexodia:RegisterEffect(e1,true)

end

function s.sendforbiddenonefilter(c)
    return c:IsSetCard(0x40) and c:IsMonster() and c:IsAbleToGrave()
end

function s.listsforbiddenonefilter(c)
    return ((c:ListsArchetype(0x40) and c:IsSpellTrap()) or c:IsCode(33244944,511000244,511000383)) and c:IsAbleToHand() --or c:IsCode()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
            and Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.sendforbiddenonefilter,tp,LOCATION_DECK,0,1,nil)
						and Duel.IsExistingMatchingCard(s.listsforbiddenonefilter,tp,LOCATION_DECK,0,1,nil)

--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
and Duel.GetFlagEffect(tp,id+2)==0
and Duel.IsExistingMatchingCard(s.sendforbiddenonefilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.listsforbiddenonefilter,tp,LOCATION_DECK,0,1,nil)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local cardtosend=Duel.SelectMatchingCard(tp, s.sendforbiddenonefilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
    if Duel.SendtoGrave(cardtosend, REASON_RULE) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local cardtoadd=Duel.SelectMatchingCard(tp, s.listsforbiddenonefilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
        Duel.SendtoHand(cardtoadd, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, cardtoadd)
    end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end
