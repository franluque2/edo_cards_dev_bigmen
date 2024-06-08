--The Ultimate Shadow Game
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
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
        e2:SetTargetRange(LOCATION_HAND,0)
        Duel.RegisterEffect(e2,tp)


        local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PREDRAW)
		e3:SetCondition(s.nodrawcon)
		e3:SetOperation(s.nodrawop)
        e3:SetCountLimit(1)
		Duel.RegisterEffect(e3,tp)



        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e4:SetCode(EVENT_MOVE)
        e4:SetCondition(s.movcon)
        e4:SetOperation(s.ctop)
		Duel.RegisterEffect(e4,tp)

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e5:SetCode(EVENT_REMOVE)
        e5:SetCondition(s.remcon)
        e5:SetOperation(s.remop)
		Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e6:SetTargetRange(1,0)
        e6:SetCode(CARD_DARK_SANCTUARY)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_DESTROY_REPLACE)
		e7:SetTarget(s.desreptg)
		e7:SetValue(s.desrepval)
		e7:SetOperation(s.desrepop)
		Duel.RegisterEffect(e7,tp)

        local e8=e7:Clone()
        e8:SetCode(EFFECT_SEND_REPLACE)
        e8:SetTarget(s.banreptg)
		Duel.RegisterEffect(e8,tp)

		local e0=Effect.CreateEffect(e:GetHandler())
        e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e0:SetCode(EVENT_ADJUST)
        e0:SetRange(0x5f)
		e0:SetCondition(s.rewritedboardcon)
        e0:SetOperation(s.rewritedboardop)
        Duel.RegisterEffect(e0,tp)
	end
	e:SetLabel(1)
end

function s.dboardrewritefilter(c)
	return c:IsOriginalCode(CARD_DESTINY_BOARD) and c:GetFlagEffect(id)==0
end

function s.rewritedboardcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.dboardrewritefilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritedboardop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.dboardrewritefilter,tp,LOCATION_ALL,0,nil)
	for tc in g:Iter() do
        if tc:GetFlagEffect(id)==0 then
		tc:RegisterFlagEffect(id,0,0,0)
		local eff={tc:GetCardEffect()}
        for _,teh in ipairs(eff) do

            if (teh:GetCode()&EVENT_LEAVE_FIELD~=0) and (Effect.GetType(teh)&(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)~=0) then
            	teh:Reset()
			end
        end
		
		
		local e3=Effect.CreateEffect(tc)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetRange(LOCATION_SZONE)
		e3:SetCode(EVENT_LEAVE_FIELD)
		e3:SetCondition(s.tgcon)
		e3:SetOperation(s.tgop)
		tc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(tc)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_LEAVE_FIELD)
		e4:SetOperation(s.tgop)
		tc:RegisterEffect(e4)
		tc:RegisterFlagEffect(id,0,0,0)

    end
	end

end

function s.cfilter1(c,tp)
	return c:IsControler(tp) and (c:IsCode(id) or c:IsSetCard(0x1c)) and not (c:IsReason(REASON_COST+REASON_REPLACE))
end
function s.cfilter2(c)
	return c:IsFaceup() and (c:IsCode(id) or c:IsSetCard(0x1c))
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,nil,tp)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_ONFIELD,0,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end

function s.repfilterban(c,tp)
	return c:IsControler(tp) and c:IsCode(CARD_DESTINY_BOARD) and c:IsLocation(LOCATION_ONFIELD)
		and c:GetDestination()==LOCATION_REMOVED and not c:IsReason(REASON_REPLACE)
end

function s.banreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return eg:IsExists(s.repfilterban,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sg=g:FilterSelect(tp,s.desfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		Duel.HintSelection(sg)
		return true
	else return false end
end

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(CARD_DESTINY_BOARD) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e,tp)
	if not (c:IsAbleToDeckAsCost()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
        and c:IsSetCard(0x1c))
		then return false end
	local dboard=Duel.GetFirstMatchingCard(Card.IsOriginalCode, tp, LOCATION_ONFIELD, 0, nil, CARD_DESTINY_BOARD)
	if not dboard then return false end
	local num=dboard:GetFlagEffect(CARD_DESTINY_BOARD)
	return c:IsCode(CARDS_SPIRIT_MESSAGE[num])

end
function s.cfilter(c)
	return c:IsAbleToDeckAsCost() and c:IsSetCard(0x1c)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local sg=g:FilterSelect(tp,s.desfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		Duel.HintSelection(sg)
		return true
	else return false end
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,tp,id)

	local tc=e:GetLabelObject()
	if Duel.SendtoDeck(tc, tp, SEQ_DECKSHUFFLE, REASON_COST+REASON_REPLACE) then

	local dboard=Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ONFIELD, 0, nil, CARD_DESTINY_BOARD):GetFirst()
	local num=dboard:GetFlagEffect(CARD_DESTINY_BOARD)
	num=num-1
	dboard:ResetFlagEffect(CARD_DESTINY_BOARD)
	for i = 1, num, 1 do
		dboard:RegisterFlagEffect(CARD_DESTINY_BOARD,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end

end



function s.efilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsCode(51644030) and c:IsLocation(LOCATION_MZONE) and
		 not (c:IsReason(REASON_SPSUMMON) or c:IsReason(REASON_SUMMON) or c:IsReason(REASON_FLIP) or c:IsPreviousLocation(LOCATION_DECK)
	 or c:IsPreviousLocation(LOCATION_HAND) or c:IsPreviousLocation(LOCATION_EXTRA) or c:IsPreviousLocation(LOCATION_GRAVE))
end

function s.movcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.efilter,1,nil)
end

function s.refilter(c)
    return c:IsCode(51644030) and c:IsLocation(LOCATION_REMOVED) and c:GetPreviousAttackOnField()~=c:GetAttack()
end

function s.remcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.refilter,1,nil)
end

function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.refilter,nil)
	for tc in g:Iter() do
        local atklabel=tc:GetPreviousAttackOnField()
        tc:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD, 0, 0)
        Card.SetFlagEffectLabel(tc, id, atklabel)
    end
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g2=eg:Filter(Card.IsFaceup,nil)
    local g=g2:Filter(s.efilter,nil)
	for tc in g:Iter() do
        local newatk=tc:GetFlagEffectLabel(id)

        if newatk then
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(newatk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		tc:RegisterEffect(e1)
    end
    end
end

function s.dbpardfilter(c)
	return c:IsCode(CARD_DESTINY_BOARD)
end


function s.flipopextra(e,tp,eg,ep,ev,re,r,rp)
	local dboard=Duel.GetFirstMatchingCard(s.dbpardfilter, tp, LOCATION_DECK, 0, nil)

    Duel.DisableShuffleCheck()

	if dboard then
		Duel.MoveSequence(dboard,0)

        for index, value in ipairs(CARDS_SPIRIT_MESSAGE) do
            local letter=Duel.CreateToken(tp, value)
            Duel.SendtoDeck(letter, tp, SEQ_DECKBOTTOM, REASON_RULE)
        end
	end

    Duel.DisableShuffleCheck(false)

end

function s.notletter(c)
    return not c:IsSetCard(0x1c)
end

function s.nodrawcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetDecktopGroup(tp, 1):IsExists(Card.IsSetCard, 1, nil, 0x1c)
end
function s.nodrawop(e,tp,eg,ep,ev,re,r,rp)
	local notletter=Duel.GetFirstMatchingCard(s.notletter, tp, LOCATION_DECK, 0, nil)
    if notletter then
		Duel.MoveSequence(notletter,0)
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

    local dbound=Duel.CreateToken(tp, 51644030)
    Duel.SpecialSummon(dbound, SUMMON_TYPE_SPECIAL, tp, tp, false,false,POS_FACEUP)

end

function s.spsummonfiendfilter(c,e,tp)
    return c:IsMonster() and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, true, true)
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.spsummonfiendfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)


	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.spsummonfiendfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)})

	if op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tosum=Duel.SelectMatchingCard(tp, s.spsummonfiendfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
    if tosum then
        Duel.SpecialSummon(tosum, SUMMON_TYPE_SPECIAL, tp,tp, true,true, POS_FACEUP)
    end

	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

