--The Decisive Duel! Awaken the Dragons!
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
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
        e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_ADD_CODE)
        e2:SetValue(CARD_DARK_MAGICIAN)
        e2:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY, 0)
        e2:SetTarget(function(_,c) return c:IsMonster() and c:IsType(TYPE_NORMAL) end)
        e2:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
        Duel.RegisterEffect(e2,tp)

        
        local e3=e2:Clone()
        e3:SetValue(CARD_BLUEEYES_W_DRAGON)
        e3:SetCondition(function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
        Duel.RegisterEffect(e3,tp)

        local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_ADD_RACE)
        e4:SetValue(RACE_WARRIOR)
        e4:SetTargetRange(LOCATION_MZONE, 0)
        e4:SetTarget(function(_,c) return c:IsMonster() and c:IsLevelBelow(4) end)
        Duel.RegisterEffect(e4,tp)


        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCondition(s.epcon)
		e5:SetOperation(s.epop)
        e5:SetCountLimit(1)
		Duel.RegisterEffect(e5,tp)


        local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_ATTACK_ANNOUNCE)
		e6:SetCondition(s.atkcon)
		e6:SetOperation(s.atkop)
		Duel.RegisterEffect(e6,tp)


	end
	e:SetLabel(1)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return a:IsControler(1-tp) and a:GetAttack()>=Duel.GetLP(tp) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and Duel.GetFlagEffect(tp, id+3)==0
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
    Duel.NegateAttack()
    Duel.Hint(HINT_CARD, tp, id)

    local rsoul=Duel.CreateToken(tp, 42776960)
    local dmg=Duel.CreateToken(tp, CARD_DARK_MAGICIAN_GIRL)

    Duel.SendtoHand(dmg, tp, REASON_RULE)
    Duel.SSet(tp, rsoul)

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    rsoul:RegisterEffect(e1)

    Duel.ConfirmCards(1-tp, dmg)
    Duel.ConfirmCards(1-tp, rsoul)

    Duel.RegisterFlagEffect(tp, id+3, 0, 0, 0)
	
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ONFIELD, 0, 1, nil, 48680970,62089826)
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)

    if Duel.GetTurnPlayer()==tp then
        local soul=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ONFIELD, 0, nil, 48680970)
        if #soul>0 then
            Duel.Hint(HINT_CARD,tp,id)
        end
        if soul and Duel.SendtoDeck(soul, tp, SEQ_DECKSHUFFLE, REASON_RULE) then

            local light
            local lights=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND, 0 , nil, 62089826)
            if #lights>1 then
                light=lights:Select(tp, 1,1,nil):GetFirst()
            else
                light=lights:GetFirst()
            end
            if light then
                Duel.MoveToField(light,tp,tp,LOCATION_SZONE,POS_FACEUP,true)


                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetDescription(3302)
                e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CANNOT_TRIGGER)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                light:RegisterEffect(e1)
            end
        end
        
    else

        local light=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ONFIELD, 0, nil, 62089826)
        if #light>0 then
            Duel.Hint(HINT_CARD,tp,id)
        end
        if light and Duel.SendtoDeck(light, tp, SEQ_DECKSHUFFLE, REASON_RULE) then
            local soul
            local souls=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND, 0 , nil, 48680970)
            if #souls>1 then
                soul=souls:Select(tp, 1,1,nil):GetFirst()
            else
                soul=souls:GetFirst()
            end
            
            if soul then
                Duel.MoveToField(soul,tp,tp,LOCATION_SZONE,POS_FACEUP,true)


                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetDescription(3302)
                e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CANNOT_TRIGGER)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                soul:RegisterEffect(e1)
            end
        end
    
    end

end



local settraps={}



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
    local darkmagician=Duel.CreateToken(tp, CARD_DARK_MAGICIAN)
    local blueeyes=Duel.CreateToken(tp, CARD_BLUEEYES_W_DRAGON)

    Duel.SendtoHand(darkmagician, tp, REASON_RULE)
    Duel.SendtoHand(blueeyes, tp, REASON_RULE)

    local g=Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_EXTRA,0,nil)

	local tc=g:GetFirst()
	while tc do
        Fusion.AddProcMix(tc,true,true,23995346,function(target,value,scard,sumtype,tp) return target:IsOriginalCode(CARD_DARK_MAGICIAN) end)

		tc=g:GetNext()
	end


end

function s.fusionfilter(c)
	return c:IsCode(62873545)
end


function s.fangofcritiasfilter(c)
    return c:IsCode(11082056) and not c:IsPublic()
end

function s.trapmatfilter(c,e,tp,rp)
    return c:IsTrap() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode(),rp) and c:IsSSetable() and not (settraps[c:GetCode()] ~= nil)
end

function s.spfilter(c,e,tp,code,rp)
	return c:IsType(TYPE_FUSION) and c.material_trap and code==c.material_trap
end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.fangofcritiasfilter,tp,LOCATION_HAND,0,1,nil)
						and Duel.IsExistingMatchingCard(s.trapmatfilter,tp,LOCATION_DECK,0,1,nil,e,tp,rp)
                        and Duel.GetLocationCount(tp, LOCATION_SZONE-LOCATION_FZONE)>0


	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,01784686)
			and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,11082056)
			and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,46232525)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
    and Duel.IsExistingMatchingCard(s.fangofcritiasfilter,tp,LOCATION_HAND,0,1,nil)
                and Duel.IsExistingMatchingCard(s.trapmatfilter,tp,LOCATION_DECK,0,1,nil,e,tp,rp)
                and Duel.GetLocationCount(tp, LOCATION_SZONE-LOCATION_FZONE)>0

local b2=Duel.GetFlagEffect(tp,id+2)==0
    and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,01784686)
    and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,11082056)
    and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,46232525)


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


function s.settrapfilter(c,code)
    return c:IsTrap() and c:IsCode(code) and c:IsSSetable() and not (settraps[tostring(c:GetCode())] ~= nil)
end

function s.revfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c.material_trap and Duel.IsExistingMatchingCard(s.settrapfilter,tp,LOCATION_DECK,0,1,nil,c.material_trap)
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

    local fang=Duel.SelectMatchingCard(tp, s.fangofcritiasfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
    if fang then
        Duel.ConfirmCards(1-tp, fang)
        local fmonster=Duel.SelectMatchingCard(tp, s.revfilter, tp, LOCATION_EXTRA, 0, 1,1,false,nil,tp):GetFirst()
        if fmonster then
            local trap=Duel.GetFirstMatchingCard(s.settrapfilter, tp, LOCATION_DECK, 0, nil, fmonster.material_trap)
            if trap then
                Duel.SSet(tp, trap)
                Duel.ConfirmCards(1-tp, trap)

                local fid=e:GetHandler():GetFieldID()
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
                e1:SetCode(EVENT_PHASE+PHASE_END)
                e1:SetCountLimit(1)
                if Duel.GetTurnPlayer()==tp then
                    e1:SetLabel(Duel.GetTurnCount())
                    e1:SetReset(RESET_PHASE+PHASE_END)
                else
                    e1:SetLabel(0)
                    e1:SetReset(RESET_PHASE+PHASE_END)
                end
                e1:SetLabelObject(trap)
                e1:SetValue(fid)
                e1:SetOperation(s.rmop)
                Duel.RegisterEffect(e1,tp)
                trap:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)

                settraps[tostring(trap:GetCode())]=1
            end
        end
    end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetValue() then
		Duel.SendtoGrave(tc, REASON_RULE)
	end
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

    local legheart=Duel.CreateToken(tp, 89397517)
    local timmy=Duel.CreateToken(tp, 80019195)
    local crit=Duel.CreateToken(tp, 85800949)
    local hermy=Duel.CreateToken(tp, 84565800)

    local celt=Duel.CreateToken(tp, 52077741)

    Duel.SendtoHand(legheart, tp, REASON_RULE)
    Duel.SendtoHand(celt, tp, REASON_RULE)

    Duel.SendtoDeck(timmy, tp, SEQ_DECKBOTTOM, REASON_RULE)
    Duel.SendtoDeck(crit, tp, SEQ_DECKBOTTOM, REASON_RULE)
    Duel.SendtoDeck(hermy, tp, SEQ_DECKBOTTOM, REASON_RULE)

    local g=Group.CreateGroup()
    g:AddCard(legheart)
    g:AddCard(celt)

    Duel.ConfirmCards(1-tp, g)


    local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetCondition(s.limcon)
	e3:SetOperation(s.limop)
    Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetCode(EVENT_CHAIN_END)
	e4:SetOperation(s.limop2)
    Duel.RegisterEffect(e4,tp)

    local e7=Effect.CreateEffect(e:GetHandler())
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e7:SetCode(EVENT_CHAINING)
    e7:SetReset(RESET_PHASE+PHASE_END)
    e7:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e7:SetOperation(s.actop)
    Duel.RegisterEffect(e7,tp)


	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if (rc:IsCode(89397517)) and ep==tp then
        Duel.SetChainLimit(s.chainlm)
    end
end

function s.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSetCard(0xa0)
end
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)>0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end