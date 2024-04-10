--Mark of the Whale
Duel.LoadScript ("big_aux.lua")

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

    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end

function s.cfilter(c,p)
	return c:IsPreviousControler(p) and c:IsReason(REASON_EFFECT) and c:GetReasonEffect():GetHandler():GetOwner()~=p and c:GetReasonEffect():GetHandler():IsRace(RACE_MACHINE)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local tg=eg:Filter(s.cfilter,nil,p)
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id, RESET_PHASE+PHASE_END, 0, 0)
		end
	end
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_SUMMON_PROC)
        e3:SetTargetRange(LOCATION_HAND,0)
        e3:SetCondition(s.ntcon)
        e3:SetTarget(aux.FieldSummonProcTg(s.nttg))
        Duel.RegisterEffect(e3,tp)


        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(s.discon)
		e2:SetOperation(s.disop)
		Duel.RegisterEffect(e2,tp)

	end
	e:SetLabel(1)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)

	local tc=re:GetHandler()

	return tc:GetFlagEffect(id)>0 and Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.fudefchacufilter, tp, LOCATION_MZONE, 0, 1, nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsCode(89493368)
end



function s.monsterfilter(c)
	return c:IsFaceup() and c:HasLevel()
end

function s.fudefchacufilter(c)
    return c:IsCode(69931927) and c:IsPosition(POS_FACEUP_DEFENSE)
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.activate_field(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 69931927)
	if g and #g>0 then
		for tc in g:Iter() do
			if tc:GetFlagEffect(id)==0 then
				tc:RegisterFlagEffect(id,0,0,0)
				local eff={tc:GetCardEffect()}
				for _,teh in ipairs(eff) do
					if teh:GetCode()&EFFECT_CANNOT_BE_BATTLE_TARGET==EFFECT_CANNOT_BE_BATTLE_TARGET then
						teh:Reset()
					end
				end
				local e3=Effect.CreateEffect(tc)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
				e3:SetRange(LOCATION_MZONE)
				e3:SetValue(1)
				tc:RegisterEffect(e3)
		end
	end
	end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.field_filter(c)
	return c:IsType(TYPE_FIELD)
end
function s.activate_field(e,tp,eg,ep,ev,re,r,rp)
	local field=Duel.SelectMatchingCard(tp,s.field_filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if #field>0 then
		Duel.ActivateFieldSpell(field:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.high_level_filter(c)
	return c:HasLevel() and c:IsLevelAbove(5) and c:IsFaceup()
end

function s.revskyfirefilter(c)
    return c:IsCode(16898077) and not c:IsPublic()
end

function s.addfilter(c)
    return c:IsCode(52286175,15175429,89493368) and c:IsAbleToHand()
end

function s.fuspellreactorsk(c)
    return c:IsCode(89493368) and c:IsFaceup()
end

function s.spsummfilter(c,e,tp)
    return c:IsCode(52286175,15175429) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false,POS_FACEUP)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0 then return end
	--Boolean checks for the activation condition: b1, b2, b3
	local b1=Duel.GetFlagEffect(tp, id+1)==0
    and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
    and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

    local b2=Duel.GetFlagEffect(ep,id+2)==0
    and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

    local b3=Duel.GetFlagEffect(ep,id+3)==0
    and Duel.IsExistingMatchingCard(s.revskyfirefilter,tp,LOCATION_HAND,0,1,nil)
    and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)


    local b4=Duel.GetFlagEffect(ep,id+4)==0
    and Duel.IsExistingMatchingCard(s.fuspellreactorsk,tp,LOCATION_ONFIELD,0,1,nil)
    and Duel.IsExistingMatchingCard(s.revskyfirefilter,tp,LOCATION_HAND,0,1,nil)
    and Duel.IsExistingMatchingCard(s.spsummfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)


	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp, id+1)==0
    and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
    and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

    local b2=Duel.GetFlagEffect(ep,id+2)==0
    and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

    local b3=Duel.GetFlagEffect(ep,id+3)==0
    and Duel.IsExistingMatchingCard(s.revskyfirefilter,tp,LOCATION_HAND,0,1,nil)
    and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)


    local b4=Duel.GetFlagEffect(ep,id+4)==0
    and Duel.IsExistingMatchingCard(s.fuspellreactorsk,tp,LOCATION_ONFIELD,0,1,nil)
    and Duel.IsExistingMatchingCard(s.revskyfirefilter,tp,LOCATION_HAND,0,1,nil)
    and Duel.IsExistingMatchingCard(s.spsummfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,4)},
                                {b2, aux.Stringid(id,1)},
                                {b3, aux.Stringid(id,2)},
                                {b4, aux.Stringid(id,3)})
	op=op-1 

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
    elseif op==1 then
        s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    elseif op==2 then
        s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    elseif op==3 then
        s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
    end
	
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.monsterfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
			local lvl=Duel.AnnounceLevel(tp,1,4)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lvl)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
            local e3=e1:Clone()
            e3:SetCode(EFFECT_ADD_TYPE)
            e3:SetValue(TYPE_TUNER)
            tc:RegisterEffect(e3)
            local e4=e1:Clone()
            e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
            e4:SetValue(ATTRIBUTE_DARK)
            tc:RegisterEffect(e4)
		end
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local skyfire=Duel.SelectMatchingCard(tp, s.revskyfirefilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
    if skyfire then
        Duel.ConfirmCards(1-tp, skyfire)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local reactor=Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
        Duel.SendtoHand(reactor, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, reactor)
    end

	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end


function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local skyfire=Duel.SelectMatchingCard(tp, s.revskyfirefilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
    if skyfire then
        Duel.ConfirmCards(1-tp, skyfire)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local reactor=Duel.SelectMatchingCard(tp, s.spsummfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
        Duel.SpecialSummon(reactor, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
    end
	
	Duel.RegisterFlagEffect(tp,id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local cearth=Duel.CreateToken(tp, 100000307)
	Duel.SSet(tp,cearth)
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end

