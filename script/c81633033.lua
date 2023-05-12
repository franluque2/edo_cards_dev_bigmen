--Hollow Shackles of Terror
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
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

       
        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)

        --cannot activate circles with the same name
        
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_CANNOT_ACTIVATE)
        e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e8:SetTargetRange(1,0)
        e8:SetValue(s.aclimit)
        Duel.RegisterEffect(e8,tp)

        --cannot control multiple ghost

        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
        e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e4:SetTargetRange(1,0)
        e4:SetTarget(s.sumlimit)
        e4:SetValue(POS_FACEDOWN)
        Duel.RegisterEffect(e4,tp)
        local e5=e4:Clone()
        e5:SetCode(EFFECT_CANNOT_SUMMON)
        Duel.RegisterEffect(e5,tp)
        local e6=e4:Clone()
        e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
        Duel.RegisterEffect(e6,tp)


        --banish the prison

        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCondition(s.epcon)
		e5:SetOperation(s.epop)
        e5:SetCountLimit(1)
		Duel.RegisterEffect(e5,tp)

        aux.GlobalCheck(s,function()
            local ge=Effect.GlobalEffect()
            ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            ge:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
            ge:SetCode(EVENT_ADJUST)
            ge:SetOperation(s.adjustop)
            Duel.RegisterEffect(ge,0)
        end)
    
        
	end
	e:SetLabel(1)
end


function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local sg=Duel.GetMatchingGroup(s.isghost, tp, LOCATION_ONFIELD, 0, nil)
	local g1=Group.CreateGroup()
	local readjust=false
	if #sg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		g1:Merge(sg:Select(tp,#sg-1,#sg-1,nil))
	end
	if #g1>0 then
		Duel.SendtoGrave(g1,REASON_RULE,PLAYER_NONE)
		readjust=true
	end
	if readjust then Duel.Readjust() end
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 511000970)
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)

    if Duel.GetTurnPlayer()==tp then
        local prison=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_GRAVE, 0, nil, 511000970)
        if prison then
            local tc=prison:GetFirst()
            while tc do

                if tc:GetFlagEffect(id)>2 then
                    Duel.Hint(HINT_CARD,tp,id)
                    Duel.Remove(tc, POS_FACEUP, REASON_RULE)
                else
                    tc:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD, 0, 0)
                end

                tc=prison:GetNext()
            end
        end
    end
        
        
end


function s.isghost(c)
    return c:IsFaceup() and c:IsCode(511002934)
end

function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local rc=Duel.GetMatchingGroupCount(s.isghost,targetp or sump,LOCATION_ONFIELD,0,nil)
	if rc==0 then return false end
	return c:IsCode(511002934)
end

function s.samecardfilter(c,code)
    return c:IsCode(code) and c:IsFaceup()
end

function s.isalreadyonfield(c)
    return c:IsCode(511003085,511000992) and Duel.IsExistingMatchingCard(s.samecardfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil, c:GetCode())
end

function s.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and s.isalreadyonfield(re:GetHandler())
end

function s.efilter(e,te)
	return e:GetOwnerPlayer()==te:GetOwnerPlayer() and te:GetHandler():IsCode(4064256)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end