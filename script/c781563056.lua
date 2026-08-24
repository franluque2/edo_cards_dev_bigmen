--All that awaits you is Darkness
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

    
     local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_STARTUP)
    e3:SetRange(0x5f)
    e3:SetCountLimit(1)
    e3:SetOperation(s.shuffledownop)
    c:RegisterEffect(e3)
	
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)

end
local DARK_ARCHETYPE=100000032


local victims={11224103,63014935,85520851,38670435,44729197,71218746,71930383,61538782,10449150,99861526,18325492,46384672,77235086,36256625,16114248,40391316,91998119,2111707,58859575,10248389,
                88264978,17132130,83104731,511001235,511001218,65192027,59712426,34568403,7541475,78658564,35975813,42386471,7572887,84430950,83982270,67316075,37057012}


function s.cardfilter(c, tp)
    return c:IsMonsterCard() and
	c:GetSequence() >= (Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) - (10))
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
	if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
	if #g > 0 then
		Duel.MoveToDeckBottom(g)
	end
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()

        --grant effects to Dark Archetype
        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(s.repcon)
		e2:SetOperation(s.repop)
		Duel.RegisterEffect(e2,tp)
        local e3=e2:Clone()
        e3:SetCode(EVENT_SUMMON_SUCCESS)
        Duel.RegisterEffect(e3,tp)
        
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetCategory(CATEGORY_TOGRAVE)
        e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e5:SetCode(EVENT_DESTROYED)
        e5:SetCondition(s.tgcon)
        e5:SetOperation(s.tgop)
        Duel.RegisterEffect(e5,tp)

        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_ADJUST)
        e1:SetCondition(s.addarchetypecon)
        e1:SetOperation(s.adddarkarchetypeop)
        Duel.RegisterEffect(e1,tp)

        local e6=Effect.CreateEffect(c)
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
        e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e6:SetTargetRange(1,0)
        e6:SetValue(2)
        Duel.RegisterEffect(e6,tp)

        local e7 = Effect.CreateEffect(c)
        e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e7:SetCode(EVENT_PREDRAW)
        e7:SetOperation(s.shuffledownop)
        e7:SetCountLimit(1)
        Duel.RegisterEffect(e7, tp)
end





function s.cfilter(c,tp)
	local rc=c:GetReasonCard()
    local re=c:GetReasonEffect()
	return c:IsMonsterCard() and (c:IsReason(REASON_BATTLE) and rc and rc:IsRelateToBattle() and rc:IsCode(DARK_ARCHETYPE)) or (c:IsReason(REASON_EFFECT) and re and re:GetOwner():IsCode(DARK_ARCHETYPE))
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter, 1, nil, tp)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter, nil, tp)
    for tc in g:Iter() do
        if tc:IsMonster() then

            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetDescription(aux.Stringid(id, 0))
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetValue(DARK_ARCHETYPE)
            tc:RegisterEffect(e1)
        end
    end
end

function s.validreplacefilter(c,e)
    return c:IsCode(DARK_ARCHETYPE) and c:IsFaceup() and c:GetReasonPlayer() ==e:GetHandlerPlayer() and c:GetFlagEffect(id)==0
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.validreplacefilter, 1, nil, e)
end

function s.copyablefilter(c)
    return c:IsMonster() and not c:IsType(TYPE_TOKEN)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,tp,id)

    eg=eg:Filter(s.validreplacefilter, nil, e)

    local tc=eg:GetFirst()
    while tc do
        if s.validreplacefilter(tc, e) and #victims>2 then
            tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_TURN_SET+RESET_LEAVE, 0, 0)
            local num1=Duel.GetRandomNumber(1, #victims )
            local num2=Duel.GetRandomNumber(1, #victims )
            while num2==num1 do
                num2=Duel.GetRandomNumber(1, #victims )
            end
            local num3=Duel.GetRandomNumber(1, #victims )
            while num3==num2 or num3==num1 do
                num3=Duel.GetRandomNumber(1, #victims )
            end

            local copyg=Duel.GetMatchingGroup(s.copyablefilter, tp, 0, LOCATION_ALL, nil)
            local option4code = nil
            local option5code = nil
            if copyg and (#copyg>0) then
                local names=copyg:GetClass(Card.GetOriginalCode)
                local randomname1=names[Duel.GetRandomNumber(1, #names)]
                local randomname2=names[Duel.GetRandomNumber(1, #names)]
                if #names>1 then
                    while randomname2==randomname1 do
                        randomname2=names[Duel.GetRandomNumber(1, #names)]
                    end
                end
                option4code=randomname1
                if randomname2 ~=randomname1 then
                    option5code=randomname2
                end
            end


            

            local option1=Duel.CreateToken(tp, victims[num1])
            local option2=Duel.CreateToken(tp, victims[num2])
            local option3=Duel.CreateToken(tp, victims[num3])
            local option4 = nil
            local option5 = nil
            if option4code then
                option4=Duel.CreateToken(tp, option4code)
            end

            if option5code then
                option5=Duel.CreateToken(tp, option5code)
            end



            local g=Group.CreateGroup()
            g:AddCard(option1)
            g:AddCard(option2)
            g:AddCard(option3)
            if option4 then
                g:AddCard(option4)
            end
            if option5 then
                g:AddCard(option5)
            end

            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_OPTION)
            local selection=g:Select(tp, 1, 1,nil):GetFirst()

            tc:CopyEffect(selection:GetCode(),RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_LEAVE,1)
            tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_LEAVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
            
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_SET_BASE_ATTACK)
            e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
            e2:SetRange(LOCATION_MZONE)
            e2:SetCondition(s.atkcon)
            e2:SetValue(selection:GetBaseAttack())
            tc:RegisterEffect(e2)
            local e3=e2:Clone()
            e3:SetCode(EFFECT_SET_BASE_DEFENSE)
            e3:SetValue(selection:GetBaseDefense())
            tc:RegisterEffect(e3)

            if selection:IsSetCard(SET_ARCANA_FORCE) then
                Duel.RaiseEvent(tc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tc:GetControler(),ev)
                Duel.RaiseSingleEvent(tc,EVENT_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tc:GetControler(),ev)
        
            end

        end
        
        tc=eg:GetNext()
    end

end

function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	local bc=e:GetHandler():GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and bc
end

function s.addarchetypecon(e,tp)
    return not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_HAND, 0, 1, nil, DARK_ARCHETYPE)
end


function s.adddarkarchetypeop(e,tp)
    local darchetype=Duel.CreateToken(tp, DARK_ARCHETYPE)
    Duel.SendtoHand(darchetype, tp, REASON_RULE)
end