--Don Thousand's Gift
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

        local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD)
		e8:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e8:SetTargetRange(LOCATION_MZONE,0)
		e8:SetTarget(s.rdtg)
		e8:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		Duel.RegisterEffect(e8,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e6:SetTargetRange(1,0)
        e6:SetTarget(s.splimit)

        local e11=Effect.CreateEffect(e:GetHandler())
        e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e11:SetTargetRange(LOCATION_MZONE,0)
        e11:SetTarget(function (_,c) return s.thousandfilter(c) end)
        e11:SetLabelObject(e6)
        Duel.RegisterEffect(e11,tp)

        local e4=e6:Clone()
        e4:SetCode(EFFECT_CANNOT_SUMMON)
        e4:SetTarget(function(_,_) return true end)

        local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e12:SetTargetRange(LOCATION_MZONE,0)
        e12:SetTarget(function (_,c) return s.thousandfilter(c) end)
        e12:SetLabelObject(e4)
        Duel.RegisterEffect(e12,tp)

        local e2=e4:Clone()
        e2:SetCode(EFFECT_CANNOT_MSET)

        local e13=Effect.CreateEffect(e:GetHandler())
        e13:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e13:SetTargetRange(LOCATION_MZONE,0)
        e13:SetTarget(function (_,c) return s.thousandfilter(c) end)
        e13:SetLabelObject(e2)
        Duel.RegisterEffect(e13,tp)


        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e7:SetCode(EVENT_CHAINING)
        e7:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e7:SetOperation(s.actop)
        Duel.RegisterEffect(e7,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_SPSUMMON_SUCCESS)
        e3:SetCondition(s.limcon)
        e3:SetOperation(s.limop)
        Duel.RegisterEffect(e3,tp)
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e5:SetCode(EVENT_CHAIN_END)
        e5:SetOperation(s.limop2)
        Duel.RegisterEffect(e5,tp)


        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
        e9:SetTargetRange(LOCATION_MZONE,0)
        e9:SetTarget(aux.TargetBoolFunction(Card.IsCode,15862758))
        e9:SetValue(s.indct)
        Duel.RegisterEffect(e9,tp)

        local e10=Effect.CreateEffect(e:GetHandler())
		e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e10:SetCode(EVENT_DAMAGE)
		e10:SetCondition(s.spcon)
		e10:SetOperation(s.spop)
		Duel.RegisterEffect(e10,tp)
    

	end
	e:SetLabel(1)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)

	local c6=(Duel.GetFlagEffect(tp, id+3)==0) and Duel.GetLP(tp)<=0

	return ep==tp and c6
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)

	if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.SetLP(tp, 1000)
		
        local ge1=Effect.CreateEffect(e:GetHandler())
        ge1:SetType(EFFECT_TYPE_FIELD)
        ge1:SetCode(EFFECT_CHANGE_DAMAGE)
        ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ge1:SetTargetRange(1,0)
        ge1:SetValue(0)
        ge1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(ge1,tp)
        local ge2=ge1:Clone()
        ge2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
        ge2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(ge2,tp)

        aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,4),nil)
	end


	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end



function s.indct(e,re,r,rp)
	if Duel.GetFlagEffect(e:GetHandlerPlayer(), id+4)==0 then
        Duel.RegisterFlagEffect(e:GetHandlerPlayer(), id+4, 0, 0, 0)
		return 1
	else return 0 end
end

function s.thousandfilter(c)
    return c:IsCode(89477759,15862758) and c:IsFaceup()
end


function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not se:GetHandler():IsCode(89477759)
end

function s.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsCode(89477759,15862758)
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
	if e:GetHandler():GetFlagEffect(id)~=0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if (rc:IsCode(41850466) or (rc:IsCode(89477759) and rc:GetLocation()&LOCATION_GRAVE~=0)) and ep==tp then
        Duel.SetChainLimit(s.chainlm)
    end
end
function s.chainlm(e,rp,tp)
    return tp==rp
end

function s.rdtg(e,c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x14b)
end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(ep,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    local nnetwork=Duel.CreateToken(tp, 41418852)
	Duel.ActivateFieldSpell(nnetwork,e,tp,eg,ep,ev,re,r,rp)

end

function s.sunyafilter(c,e,tp)
    return c:IsCode(79747096) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.funumberfilter(c)
    return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.setthousandbackrowfilter(c)
    return c:IsCode(56673480,93238626) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end

function s.umbralhorrorfilter(c)
    return c:IsSetCard(0x87) and c:IsFaceup() and c:HasLevel()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+5)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.funumberfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.setthousandbackrowfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
            and Duel.GetFlagEffect(tp, id+3)>0
			and Duel.IsExistingMatchingCard(s.sunyafilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
            and Duel.GetLocationCount(tp, LOCATION_SZONE)>0
    
    local b3=Duel.GetFlagEffect(tp, id+5)==0
        and Duel.IsExistingMatchingCard(s.umbralhorrorfilter, tp, LOCATION_MZONE, 0, 1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
    and Duel.IsExistingMatchingCard(s.funumberfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.setthousandbackrowfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

local b2=Duel.GetFlagEffect(tp,id+2)==0
    and Duel.GetFlagEffect(tp, id+3)>0
    and Duel.IsExistingMatchingCard(s.sunyafilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    and Duel.GetLocationCount(tp, LOCATION_SZONE)>0

local b3=Duel.GetFlagEffect(tp, id+5)==0
    and Duel.IsExistingMatchingCard(s.umbralhorrorfilter, tp, LOCATION_MZONE, 0, 1,nil)




--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
                                  {b3,aux.Stringid(id,6)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    elseif op==2 then
        s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp, s.setthousandbackrowfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1,1,false,nil)
    if tc then
        Duel.SSet(tp, tc)
    end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
    if g then
        Duel.Remove(g, POS_FACEUP, REASON_RULE)
    end

    local tc=Duel.SelectMatchingCard(tp, s.sunyafilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, 1,false,nil,e,tp)
    if tc then
        if Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false,false,POS_FACEUP) then
            local ritual=Duel.CreateToken(tp, 41850466)
            Duel.SSet(tp, ritual)

            local e7=Effect.CreateEffect(e:GetHandler())
            e7:SetDescription(aux.Stringid(id,2))
            e7:SetType(EFFECT_TYPE_IGNITION)
            e7:SetCategory(CATEGORY_DESTROY)
            e7:SetRange(LOCATION_MZONE)
            e7:SetTarget(s.destg)
            e7:SetOperation(s.desop)
            tc:GetFirst():RegisterEffect(e7)
        end
    end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    local level=Duel.AnnounceLevel(tp,1,5)

    local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_LEVEL)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetValue(level)
    e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTarget(function(_,c) return s.umbralhorrorfilter(c) end)
    Duel.RegisterEffect(e4, tp)


	Duel.RegisterFlagEffect(tp,id+5,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.numnetworkfilter(c)
    return c:IsCode(41418852) and c:IsFaceup() and c:IsDestructable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT) then
        if Duel.IsExistingMatchingCard(s.numnetworkfilter, tp, LOCATION_ONFIELD, 0, 1,nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 5)) then
            local tc=Duel.SelectMatchingCard(tp, s.numnetworkfilter, tp, LOCATION_ONFIELD, 0, 1,1,false,nil)
            if tc then
                Duel.Destroy(tc, REASON_EFFECT)
            end
        end

        local ge1=Effect.CreateEffect(e:GetHandler())
        ge1:SetType(EFFECT_TYPE_FIELD)
        ge1:SetCode(EFFECT_CHANGE_DAMAGE)
        ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ge1:SetTargetRange(0,1)
        ge1:SetValue(0)
        ge1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(ge1,tp)
        local ge2=ge1:Clone()
        ge2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
        ge2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(ge2,tp)
    end
end
