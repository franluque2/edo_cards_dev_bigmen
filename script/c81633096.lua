--The Climax! ESPer Robin's Final Bout!
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

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_CODE)
        e5:SetTargetRange(LOCATION_DECK,0)
        e5:SetTarget(function(_,c)  return c:IsOriginalCode(79185500,16796157) end)
        e5:SetValue(43791861)
        Duel.RegisterEffect(e5,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetDescription(aux.Stringid(id,8))
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_SUMMON_PROC)
        e3:SetTargetRange(LOCATION_HAND,0)
        e3:SetCondition(s.ntcon)
        e3:SetTarget(aux.FieldSummonProcTg(s.nttg))
        Duel.RegisterEffect(e3,tp)

        local e0=Effect.CreateEffect(e:GetHandler())
        e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e0:SetCode(EVENT_STARTUP)
        e0:SetRange(0x5f)
        e0:SetOperation(s.makequickop)
        Duel.RegisterEffect(e0,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DESTROY_REPLACE)
		e2:SetTarget(s.desreptg)
		e2:SetValue(s.desrepval)
		e2:SetOperation(s.desrepop)
		Duel.RegisterEffect(e2,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_DESTROYED)
		e6:SetCondition(s.descon)
		e6:SetOperation(s.desop)
        e6:SetCountLimit(1)
		Duel.RegisterEffect(e6,tp)

        local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCondition(s.epcon)
		e4:SetOperation(s.epop)
        e4:SetCountLimit(1)
		Duel.RegisterEffect(e4,tp)

	end
	e:SetLabel(1)
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_GRAVE, 0, 1, nil, 80208158) and
        not Duel.IsExistingMatchingCard(s.fusparrowfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.setsparrowforeverfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil)
		and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp, id+8)==0
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        local card=Duel.SelectMatchingCard(tp, s.setsparrowforeverfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, 1,false,nil)
        if Duel.SSet(tp, card) then
            Duel.ConfirmCards(1-tp, card)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(3300)
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            card:GetFirst():RegisterEffect(e1,true)
        end
		Duel.RegisterFlagEffect(tp, id+8, 0, 0, 0)
    end
end

function s.cfilter1(c,e,tp)
	return c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()~=tp
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsCode(66523544) and Duel.IsExistingMatchingCard(s.spsummonnotjrionfilter, tp, LOCATION_GRAVE, 0, 1, nil,e,tp)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,nil,e,tp)
end
--

function s.desop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,id)
        local tc=eg:Filter(s.cfilter, nil, e,tp):GetFirst()
		if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
			local g=Duel.SelectMatchingCard(tp, s.spsummonnotjrionfilter, tp, LOCATION_GRAVE, 0, 1, tc:GetOverlayCount(),false,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
			end
			Duel.RegisterFlagEffect(tp, id+5, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
		end

end

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(15574615) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e,tp)
	return c:IsAbleToRemoveAsCost()
end
function s.cfilter(c)
	return c:IsCode(100000220) and c:IsAbleToRemoveAsCost()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 6)) then
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


function s.makequickop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --jet iron
	local g=Duel.GetMatchingGroup(Card.IsOriginalCode,tp,LOCATION_ALL,0,nil,15574615)
	for tc in g:Iter() do
        if tc:GetFlagEffect(id)==0 then
		tc:RegisterFlagEffect(id,0,0,0)
		local eff={tc:GetCardEffect()}
        for _,teh in ipairs(eff) do
            teh:Reset()
        end
		
		

        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_SPSUMMON_PROC)
        e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
        e1:SetRange(LOCATION_HAND)
        e1:SetCondition(s.spcon)
        e1:SetTarget(s.sptg)
        e1:SetOperation(s.spop)
        tc:RegisterEffect(e1)
        --Special Summon monsters
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(tc:GetCode(),0))
        e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e2:SetType(EFFECT_TYPE_QUICK_O)
        e2:SetCode(EVENT_FREE_CHAIN)
        e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(s.maincon)
        e2:SetCost(s.cost)
        e2:SetTarget(s.target)
        e2:SetOperation(s.operation)
        tc:RegisterEffect(e2)
    end
	end

    --Galaxy Queen
	g=Duel.GetMatchingGroup(Card.IsOriginalCode,tp,LOCATION_ALL,0,nil,48928529)
	for tc in g:Iter() do
        if tc:GetFlagEffect(id)==0 then
		tc:RegisterFlagEffect(id,0,0,0)
		local eff={tc:GetCardEffect()}
        for _,teh in ipairs(eff) do
            teh:Reset()
        end
        --Must be properly summoned before reviving
        tc:EnableReviveLimit()
        --Xyz summon procedure
        Xyz.AddProcedure(tc,nil,1,3)
        --Your current monsters cannot be destroyed by battle, also they inflict piercing damage
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(tc:GetCode(),0))
        e1:SetType(EFFECT_TYPE_QUICK_O)
        e1:SetCode(EVENT_FREE_CHAIN)
        e1:SetCountLimit(1,tc:GetCode())
		e1:SetCondition(s.maincon)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCost(s.gqueencost)
        e1:SetOperation(s.gqueenoperation)
        tc:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
    end
	end
end

function s.maincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsCode(43791861)
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.discardesperfilter(c)
    return c:IsCode(80208158) and c:IsDiscardable(REASON_COST)
end

function s.addfriendfilter(c)
    return c:IsCode(16796157,79185500,43791861) and c:IsAbleToHand()
end

function s.fusparrowfilter(c)
    return c:IsCode(80208158) and c:IsFaceup()
end

function s.setsparrowforeverfilter(c)
    return c:IsCode(511001067) and c:IsSSetable()
end

function s.spsummonfriendfilter(c,e,tp)
    return c:IsCode(16796157,79185500,43791861) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP)
end

function s.setbackrowfilter(c)
    return c:IsCode(511001037,100000285) and c:IsSSetable()
end

function s.spsummonnotjrionfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP) and c:IsLevelBelow(10) and not c:IsCode(15574615)
end

function s.fupumafilter(c)
    return c:IsCode(16796157) and c:IsFaceup()
end

function s.fugairudafilter(c)
    return c:IsCode(79185500) and c:IsFaceup()
end

function s.fuironhammerfilter(c)
    return c:IsCode(43791861) and c:IsFaceup()
end



function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0  then return end

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.discardesperfilter,tp,LOCATION_HAND,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addfriendfilter,tp,LOCATION_DECK,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.fusparrowfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.spsummonfriendfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1, nil, e, tp)

    local b3=Duel.GetFlagEffect(tp,id+2)==0
        and Duel.IsExistingMatchingCard(s.fusparrowfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.setbackrowfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil)

    local b4=Duel.GetFlagEffect(tp,id+3)==0
        and Duel.IsExistingMatchingCard(s.fusparrowfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fupumafilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fugairudafilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fuironhammerfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and (Duel.GetLocationCount(tp, LOCATION_SZONE)>0)

    local b5=Duel.GetFlagEffect(tp,id+3)==0
        and Duel.IsExistingMatchingCard(s.fusparrowfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fupumafilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fugairudafilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fuironhammerfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.HasLevel,tp,LOCATION_MZONE,0,3,nil)



	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4 or b5)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.discardesperfilter,tp,LOCATION_HAND,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addfriendfilter,tp,LOCATION_DECK,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.fusparrowfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.spsummonfriendfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1, nil, e, tp)

    local b3=Duel.GetFlagEffect(tp,id+2)==0
        and Duel.IsExistingMatchingCard(s.fusparrowfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.setbackrowfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil)

    local b4=Duel.GetFlagEffect(tp,id+3)==0
        and Duel.IsExistingMatchingCard(s.fusparrowfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fupumafilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fugairudafilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fuironhammerfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and (Duel.GetLocationCount(tp, LOCATION_SZONE)>0)

    local b5=Duel.GetFlagEffect(tp,id+3)==0
        and Duel.IsExistingMatchingCard(s.fusparrowfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fupumafilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fugairudafilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.fuironhammerfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.HasLevel,tp,LOCATION_MZONE,0,3,nil)


--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,2)},
								  {b3,aux.Stringid(id,3)},
								  {b4,aux.Stringid(id,4)},
								  {b5,aux.Stringid(id,5)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    elseif op==3 then
		s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
    elseif op==4 then
		s.operation_for_res4(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    Duel.DiscardHand(tp,s.discardesperfilter,1,1,REASON_COST+REASON_DISCARD,nil)
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local add=Duel.SelectMatchingCard(tp, s.addfriendfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
    if add and Duel.SendtoHand(add, tp, REASON_RULE) then
        Duel.ConfirmCards(1-tp, add)
    end


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local friend=Duel.SelectMatchingCard(tp, s.spsummonfriendfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
    if friend then
        Duel.SpecialSummon(friend, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
    end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local set=Duel.SelectMatchingCard(tp, s.setbackrowfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1,1,false,nil)
    if set and Duel.SSet(tp, set) then
        Duel.ConfirmCards(1-tp, set)
    end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
    local change=Duel.CreateToken(tp, 100000220)
    Duel.SSet(tp, change)
    Duel.ConfirmCards(1-tp, change)

    local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			change:RegisterEffect(e1)

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.fuhaslevelfilter(c)
	return c:HasLevel() and c:IsFaceup()
end
function s.operation_for_res4(e,tp,eg,ep,ev,re,r,rp)
    local tochange=Duel.SelectMatchingCard(tp, s.fuhaslevelfilter, tp, LOCATION_MZONE, 0, 3,3,false,nil)
    if tochange then
		for tc in tochange:Iter() do
			
		
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		end
    end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end



--jet iron eff to keep here

function s.chk(c,sg,g,code,...)
	if not c:IsCode(code) then return false end
	local res
	if ... then
		g:AddCard(c)
		res=sg:IsExists(s.chk,1,g,sg,g,...)
		g:RemoveCard(c)
	else
		res=true
	end
	return res
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),80208158,16796157,43791861,79185500)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	local g1=rg:Filter(Card.IsCode,nil,80208158)
	local g2=rg:Filter(Card.IsCode,nil,16796157)
	local g3=rg:Filter(Card.IsCode,nil,43791861)
	local g4=rg:Filter(Card.IsCode,nil,79185500)
	local g=g1:Clone()
	g:Merge(g2)
	g:Merge(g3)
	g:Merge(g4)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-4 and #g1>0 and #g2>0 and #g3>0 and #g4>0
		and aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_MZONE,0,nil):Filter(Card.IsCode,nil,80208158,16796157,43791861,79185500)
	local g=aux.SelectUnselectGroup(rg,e,tp,4,4,s.rescon,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,80208158)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,16796157)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,43791861)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,79185500)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,80208158)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,16796157)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g3=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,43791861)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g4=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,79185500)
	g1:Merge(g2)
	g1:Merge(g3)
	g1:Merge(g4)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,4,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetTargetCards(e)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if #g>ft then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end


--galaxy queen eff to keep here

function s.gqueencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.gqueenoperation(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		--Inflict piercing damage
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3208)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
	end
end