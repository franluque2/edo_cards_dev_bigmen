--The Fate of Rush Duels! The Sevens Road!
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
		bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

		local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_FUSION_SUBSTITUTE)
        e12:SetTargetRange(LOCATION_ALL,0)
        e12:SetTarget(function(_,c)  return c:IsCode(CARD_SEVENS_ROAD_MAGICIAN) end)
		e12:SetValue(s.subval)

        Duel.RegisterEffect(e12,tp)

		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_DESTROYED)
		e6:SetCondition(s.descon)
		e6:SetOperation(s.desop)
        e6:SetCountLimit(1)
		Duel.RegisterEffect(e6,tp)

		s.filltables()


	end
	e:SetLabel(1)
end

local MAXIMUM_CENTERS={160202002,160203002,160207002,160005015,160202011,160004022,160422002}

local maximums={}
maximums[0]=Group.CreateGroup()
maximums[1]=Group.CreateGroup()


function s.filltables()
    if #maximums[0]==0 then
        for i, v in pairs(MAXIMUM_CENTERS) do
            local token1=Duel.CreateToken(0, v)
            maximums[0]:AddCard(token1)
            local token2=Duel.CreateToken(1, v)
            maximums[1]:AddCard(token2)


        end
    end
end

function s.subval(e,c)
    return not c:ListsCodeAsMaterial(CARD_SEVENS_ROAD_MAGICIAN)
end

function s.cfilter1(c,e,tp)
	return c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()~=tp
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsLevelAbove(9)
		
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,nil,e,tp) and Duel.GetFlagEffect(tp, id+3)==0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>6
end
--
function s.sumfilter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,id)
		if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
			local g=Duel.GetDecktopGroup(tp, 7)
			Duel.ConfirmDecktop(tp, 7)
			local sum=g:Filter(s.sumfilter, nil,e,tp)
			if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
				local zones=Duel.GetLocationCount(tp, LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
				local tosum=Group.Select(sum, tp, 1, zones,nil)
				Duel.SpecialSummon(tosum, SUMMON_TYPE_SPECIAL, tp, tp, false, false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)
				g=g:RemoveCard(tosum)
			end
			Duel.SendtoGrave(g, REASON_RULE)
			Duel.RegisterFlagEffect(tp, id+3, 0, 0, 0)
		end

end


local kuribotids={160001017,160202004,160204019,160202004,160416005,160416006,160416007}

function s.getrandomkuribotid()
    return kuribotids[Duel.GetRandomNumber(1,#kuribotids)]
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

    s.taghighlevels(e, tp, eg, ep, ev, re, r, rp)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.effcon(e, c)
	return c:IsLevelAbove(7)
end

function s.highlevelfilter(c)
	return c:IsLevelAbove(7)
end

function s.taghighlevels(e, tp, eg, ep, ev, re, r, rp)
	local legends = Duel.GetMatchingGroup(s.highlevelfilter, tp, LOCATION_ALL, 0, nil)

	for tc in legends:Iter() do
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
		e1:SetValue(s.effcon)
		tc:RegisterEffect(e1)
	end
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    for i = 1, 3, 1 do
        local kurivot=Duel.CreateToken(tp, s.getrandomkuribotid())
        Duel.SendtoGrave(kurivot, REASON_RULE)
    end

    for i = 1, 3, 1 do
        local kurivot=Duel.CreateToken(tp, s.getrandomkuribotid())
        Duel.SendtoDeck(kurivot, tp, SEQ_DECKBOTTOM, REASON_RULE)
    end

    local kurivot=Duel.CreateToken(tp, s.getrandomkuribotid())
    Duel.SendtoHand(kurivot, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, kurivot)


end


function s.sumhandfilter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false,POS_FACEUP) and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.fuhighfilter(c)
	return c:IsLevelAbove(7) and c:IsFaceup()
end

function s.summonedmaximummonster(c)
    return c:IsMaximumMode()
end

function s.sumnofusfilter(c,e,tp)
	return c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false,POS_FACEUP) and not c:IsType(TYPE_FUSION)
end

function s.level7filter(c)
	return c:IsLevelAbove(7) and not c:IsType(TYPE_MAXIMUM) and not c:IsPublic()
end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+4)>0   then return end
	--Boolean checks for the activation condition: b1, b2

	local g=Duel.GetMatchingGroup(s.level7filter, tp, LOCATION_HAND, 0, nil)

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.fuhighfilter,tp,LOCATION_MZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.sumhandfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
						and Duel.CheckLPCost(tp, 700)
						and Duel.GetLocationCount(tp, LOCATION_MZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
		and Duel.IsExistingMatchingCard(s.summonedmaximummonster,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.sumnofusfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)

		local b3=Duel.GetFlagEffect(tp,id+4)==0
		and g:GetClassCount(Card.GetCode)>2
		and #maximums[tp]>0



--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)

	local g=Duel.GetMatchingGroup(s.level7filter, tp, LOCATION_HAND, 0, nil)

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.fuhighfilter,tp,LOCATION_MZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(s.sumhandfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
						and Duel.CheckLPCost(tp, 700)
						and Duel.GetLocationCount(tp, LOCATION_MZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
		and Duel.IsExistingMatchingCard(s.summonedmaximummonster,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.sumnofusfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)

		local b3=Duel.GetFlagEffect(tp,id+4)==0
		and g:GetClassCount(Card.GetCode)>2
		and #maximums[tp]>0


--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,4)})
	op=op-1 

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp, 700)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp, s.sumhandfilter, tp, LOCATION_HAND, 0, 1,1,false,nil,e,tp)
	if tc then
		Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp,tp, false,false, POS_FACEUP)
	end

--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_MZONE, 0, nil)
	Duel.SendtoDeck(g, tp, SEQ_DECKBOTTOM, REASON_RULE)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp, s.sumnofusfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
	if tc then
		Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp,tp, false,false, POS_FACEUP)
	end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g2=Duel.GetMatchingGroup(s.level7filter, tp, LOCATION_HAND, 0, nil)
	local g=aux.SelectUnselectGroup(g2,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_CONFIRM)
    if g then

        Duel.ConfirmCards(1-tp, g)

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local tar=maximums[tp]:Select(tp,1,1,nil):GetFirst()
        maximums[tp]:RemoveCard(tar)

        local tar1=Duel.CreateToken(tp, tar:GetCode()+1)
        local tar2=Duel.CreateToken(tp, tar:GetCode()-1)

        local cards=Group.CreateGroup()
        cards:AddCard(tar)
        cards:AddCard(tar2)
        cards:AddCard(tar1)

        Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_RULE)

        Duel.SendtoHand(cards, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, cards)


    end
	Duel.RegisterFlagEffect(tp,id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
