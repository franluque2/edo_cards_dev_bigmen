--In Your Future, There Is Darkness
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
	aux.AddSkillProcedure(c,2,false,nil,nil)

    
end
local DARK_ARCHETYPE=100000032


local victims={11224103,63014935,85520851,38670435,44729197,71218746,71930383,61538782,10449150,99861526,18325492,46384672,77235086,36256625,16114248,40391316,91998119,2111707,58859575,10248389}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

         --skip draw to add darchetype
         local e8=Effect.CreateEffect(e:GetHandler())
         e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
         e8:SetCode(EVENT_PREDRAW)
         e8:SetCondition(s.addcon)
         e8:SetOperation(s.addop)
         Duel.RegisterEffect(e8,tp)

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



	end
	e:SetLabel(1)
end

function s.cfilter(c,tp)
	local rc=c:GetReasonCard()
    local re=c:GetReasonEffect()
	return c:IsMonster() and (c:IsReason(REASON_BATTLE) and rc and rc:IsRelateToBattle() and rc:IsCode(DARK_ARCHETYPE)) or (c:IsReason(REASON_EFFECT) and re and re:GetOwner():IsCode(DARK_ARCHETYPE))
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
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetValue(DARK_ARCHETYPE)
            tc:RegisterEffect(e1)
        end
    end
end

function s.atohanddarchetypefilter(c)
    return c:IsCode(DARK_ARCHETYPE) and c:IsAbleToHand()
end

function s.validreplacefilter(c,e)
    return c:IsCode(DARK_ARCHETYPE) and c:IsFaceup() and c:GetReasonPlayer() ==e:GetHandlerPlayer()
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.validreplacefilter, 1, nil, e)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.Hint(HINT_CARD,tp,id)

    local tc=eg:GetFirst()
    while tc do
        if s.validreplacefilter(tc, e) and #victims>2 then
            local num1=Duel.GetRandomNumber(1, #victims )
            local num2=Duel.GetRandomNumber(1, #victims )
            while num2==num1 do
                num2=Duel.GetRandomNumber(1, #victims )
            end
            local num3=Duel.GetRandomNumber(1, #victims )
            while num3==num2 or num3==num1 do
                num3=Duel.GetRandomNumber(1, #victims )
            end

            local option1=Duel.CreateToken(tp, victims[num1])
            local option2=Duel.CreateToken(tp, victims[num2])
            local option3=Duel.CreateToken(tp, victims[num3])

            local g=Group.CreateGroup()
            g:AddCard(option1)
            g:AddCard(option2)
            g:AddCard(option3)

            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_OPTION)
            local selection=g:Select(tp, 1, 1,nil):GetFirst()

            if selection==option1 then
                table.remove(victims,num1)
            end
            if selection==option2 then
                table.remove(victims,num2)
            end
            if selection==option3 then
                table.remove(victims,num3)
            end


            tc:CopyEffect(selection:GetCode(),RESET_EVENT+RESETS_STANDARD,1)
            tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
            
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

        end
        
        tc=eg:GetNext()
    end

end

function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	local bc=e:GetHandler():GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and bc
end



function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+1)==0
         and Duel.GetDrawCount(tp)>0 and Duel.IsExistingMatchingCard(s.atohanddarchetypefilter, tp, LOCATION_DECK+LOCATION_GRAVE, LOCATION_GRAVE, 1, nil)
         and Duel.GetTurnCount()>1
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_CARD,tp,id)
        local dt=Duel.GetDrawCount(tp)
        if dt~=0 then
            _replace_count=0
            _replace_max=dt
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetCode(EFFECT_DRAW_COUNT)
            e1:SetTargetRange(1,0)
            e1:SetReset(RESET_PHASE+PHASE_DRAW)
            e1:SetValue(0)
            Duel.RegisterEffect(e1,tp)
        end
        
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local card=Duel.SelectMatchingCard(tp, s.atohanddarchetypefilter, tp, LOCATION_DECK+LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, false, nil)
        Duel.SendtoHand(card, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, card)
    end
	Duel.RegisterFlagEffect(ep,id+1,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.darkarchetypefilter(c)
	return c:IsCode(DARK_ARCHETYPE)
end


function s.flipopextra(e,tp,eg,ep,ev,re,r,rp)
	local darchetype=Duel.GetFirstMatchingCard(s.darkarchetypefilter, tp, LOCATION_DECK, 0, nil)

    Duel.DisableShuffleCheck()

	if darchetype then
		Duel.MoveSequence(darchetype,0)
	end

    Duel.DisableShuffleCheck(false)

end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

