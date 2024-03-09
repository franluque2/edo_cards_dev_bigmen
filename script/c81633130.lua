--The Radiant First Velgearian
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

		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetTargetRange(LOCATION_GRAVE,0)
		e7:SetCode(EFFECT_ADD_TYPE)
		e7:SetTarget(s.chtg3)
		e7:SetValue(TYPE_NORMAL)
		Duel.RegisterEffect(e7, tp)

        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetDescription(aux.Stringid(id,0))
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_SUMMON_PROC)
        e4:SetCondition(s.ntcon)

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetCode(EFFECT_SUMMON_COST)
        e5:SetOperation(s.lvop)


        local e15=Effect.CreateEffect(e:GetHandler())
        e15:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e15:SetTargetRange(LOCATION_HAND,0)
        e15:SetTarget(aux.TargetBoolFunction(s.highlevelfilter))
        e15:SetLabelObject(e4)
		Duel.RegisterEffect(e15,tp)
        local e16=e15:Clone()
        e16:SetLabelObject(e5)
        Duel.RegisterEffect(e16,tp)


	end
	e:SetLabel(1)
end
function s.highlevelfilter(c)
    return c:IsLevelAbove(7)
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.lvcon)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
	c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e3)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
    e1:SetCondition(s.lvcon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD&~RESET_TOFIELD)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DISABLE_EFFECT)
    e4:SetCondition(s.lvcon)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD&~RESET_TOFIELD)
	c:RegisterEffect(e4)


    local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_CHAINING)
		e5:SetOperation(s.actop)
		Duel.RegisterEffect(e5,tp)


        local e13=Effect.CreateEffect(e:GetHandler())
		e13:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e13:SetCode(EFFECT_DESTROY_REPLACE)
		e13:SetTarget(s.desreptg)
		e13:SetValue(s.desrepval)
		e13:SetCountLimit(1)
		e13:SetOperation(s.desrepop)
		Duel.RegisterEffect(e13,tp)
end
function s.chtg3(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(1)
end

function s.repfilter(c,tp)
	return c:IsControler(tp) and (c:IsCode(160016039, 160016008)) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsLevelAbove(7)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e,tp)
	return c:IsAbleToRemoveAsCost()
end
function s.cfilter(c)
	return c:IsCode(160016048) and c:IsAbleToRemoveAsCost()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 2)) then
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
	local tc=e:GetLabelObject()
	Duel.Remove(tc, POS_FACEUP, REASON_REPLACE)
end


function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if (rc:IsCode(160016001) or rc:IsCode(CARD_FUSION)) then
		Duel.SetChainLimit(s.chainlm)
	end
end

function s.chainlm(e,rp,tp)
	return tp==rp
end


function s.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
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

    local fullarmornova=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil,160016039)
    for tc in fullarmornova:Iter() do
        Fusion.AddProcMix(tc,true,true,s.praimarmorfilter,s.oppmonsfilter)
    end

    local praimegiant=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil,160016037)
    for tc in praimegiant:Iter() do
        Fusion.AddProcMix(tc,true,true,160016001,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT))
    end
end

function s.praimarmorfilter(c)
    return c:IsCode(160016008) and c:GetMaterialCount()==3
end

function s.oppmonsfilter(c,fc,sumtype,tp,sub,mg,sg)
    return c:GetControler()~=tp
end

function s.fudwarffilter(c)
    return c:IsCode(160016001) and c:IsFaceup()
end

function s.praimebanishspellfilter(c)
    return c:IsCode(160016048,81632539) and c:IsAbleToRemoveAsCost()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.fudwarffilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.praimebanishspellfilter,tp,LOCATION_GRAVE,0,1,nil)

--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end


function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
and Duel.IsExistingMatchingCard(s.fudwarffilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.praimebanishspellfilter,tp,LOCATION_GRAVE,0,1,nil)


--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local tobanish=Duel.SelectMatchingCard(tp, s.praimebanishspellfilter, tp, LOCATION_GRAVE, 0, 1, 1, false, nil)
    if Duel.Remove(tobanish, POS_FACEUP, REASON_COST) then
        local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e4:SetTargetRange(0,LOCATION_MZONE)
			e4:SetValue(ATTRIBUTE_LIGHT)
			e4:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e4,tp)
    end



--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end