--Drown in Endless Darkness
Duel.LoadScript ("big_skill_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1, e2=BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local DARK_ARCHETYPE=100000032


local victims={64268668,11224103,54514594,44729197,71218746,80344569,46384672,77235086,34568403,7541475,78658564,35975813,7572887,37043180,20003527,67316075,10509340,1953925,70095154,18000338,4058065,52319752,81059524,89731911,76763417,13093792,63695531,32933942,61116514,78663366,65192027,16114248,40391316,2111707,58859575,99724761,25119460}


function s.flipconpassive(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))

    
     local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetCondition(s.repcon)
		e2:SetOperation(s.repop)
		Duel.RegisterEffect(e2,tp)
        local e3=e2:Clone()
        e3:SetCode(EVENT_SUMMON_SUCCESS)
        Duel.RegisterEffect(e3,tp)

end



function s.validreplacefilter(c,e)
    return c:IsCode(DARK_ARCHETYPE) and c:IsFaceup() and c:GetReasonPlayer() ==e:GetHandlerPlayer() and c:GetFlagEffect(id)==0
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.validreplacefilter, 1, nil, e)
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
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_OPTION)
            local tocreate=Duel.SelectCardsFromCodes(tp,1,1,false,false,victims[num1],victims[num2],victims[num3])
            local selection=Duel.CreateToken(tp, tocreate)

            tc:CopyEffect(selection:GetCode(),RESET_EVENT+RESETS_STANDARD+RESET_TURN_SET+RESET_LEAVE,1)
            tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_TURN_SET+RESET_LEAVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
            
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_SET_BASE_ATTACK)
            e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_TURN_SET)
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
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
end
