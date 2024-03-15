--Dragonic Mosaic
--add archetype Template
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



--change this to change the locations where this acts
local LOCATIONS=LOCATION_ALL-LOCATION_OVERLAY

--add archetype setcode here
local ARCHETYPE=0x1186

--add the conditions for the archetype swap here
function s.MaterialMosiac(c)
  return c:IsCode(511002423, 511002424, 511002422, 511002421, 511002425)
end

function s.Mosiac(c)
  return c:IsOriginalCode(511002425)
end

function s.OfD(c)
  return c:IsCode(67511500, 08978197, 17985575, 66961194, 160319005)
end

function s.Virus(c)
  return c:IsOriginalCode(800000012)
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

        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_ADD_SETCODE)
        e5:SetTargetRange(LOCATIONS,0)
        e5:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e5:SetValue(0xdd)
        Duel.RegisterEffect(e5,tp)

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_RACE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(function(_,c)  return c:IsHasEffect(id) end)
        e6:SetValue(RACE_DRAGON)
        Duel.RegisterEffect(e6,tp)

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_SETCODE)
        e7:SetTargetRange(LOCATIONS,0)
        e7:SetTarget(function(_,c)  return c:IsHasEffect(id+2) end)
        e7:SetValue(0xdd)
        Duel.RegisterEffect(e7,tp)

        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetCode(EFFECT_ADD_CODE)
        e8:SetTargetRange(LOCATION_GRAVE,0)
        e8:SetTarget(function(_,c)  return c:IsHasEffect(id+1) end)
        e8:SetValue(10000000)
        Duel.RegisterEffect(e8,tp)

		local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_CHANGE_CODE)
        e9:SetTargetRange(LOCATION_FZONE,0)
        e9:SetTarget(function(_,c)  return c:IsHasEffect(id+3) end)
        e9:SetValue(57728570)
        Duel.RegisterEffect(e9,tp)

		local e17=Effect.CreateEffect(e:GetHandler())
		e17:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e17:SetCode(EVENT_CHAINING)
		e17:SetCondition(s.sumcon)
		e17:SetOperation(s.sumop)
        e17:SetCountLimit(1)
		Duel.RegisterEffect(e17,tp)
    

	end
	e:SetLabel(1)
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL)
		and re:GetHandler():IsOriginalCode(800000012)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp, id+9, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end



function s.markedfilter(c,e)
    return #c:IsHasEffect(e)>0
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local g=Duel.GetMatchingGroup(s.MaterialMosiac, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

    g=Duel.GetMatchingGroup(s.Mosiac, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+1)
				tc:RegisterEffect(e3)

				Fusion.AddContactProc(tc,s.contactfilter,s.contactop)

			tc=g:GetNext()
		end
	end

    
    g=Duel.GetMatchingGroup(s.OfD, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+2)
				tc:RegisterEffect(e3)


			tc=g:GetNext()
		end
	end

	g=Duel.GetMatchingGroup(s.Virus, tp, LOCATION_ALL, LOCATION_ALL, nil)

    if #g>0 then
		local tc=g:GetFirst()
		while tc do
			
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(id+3)
				tc:RegisterEffect(e3)

				Fusion.AddContactProc(tc,s.contactfilter,s.contactop)

			tc=g:GetNext()
		end
	end

	g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, LOCATION_ALL, nil, 13756293)
	for tc in g:Iter() do
		Fusion.AddProcMix(tc,true,true,17985575,s.MaterialMosiac)

	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.contactfilter(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND|LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end

function s.armadillodiscard(c)
	return c:IsCode(511002421) and c:IsDiscardable(REASON_COST)
end

function s.materialadd(c)
	return s.MaterialMosiac(c) and c:IsAbleToHand() and not c:IsCode(511002421)
end

function s.spsummondfilter(c,e,tp,c2)
	return s.OfD(c) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false) and not c:IsOriginalCode(c2)
end


function s.tributeD(c,e,tp)
	return s.OfD(c) and c:IsReleasable() and Duel.IsExistingMatchingCard(s.spsummondfilter, tp, LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK, 0, 1, nil, e, tp, c:GetOriginalCode())
end


function s.tributecheckfilter(c,code)
	return c:IsCode(code) and c:IsReleasable()
end

function s.addvaccinationfilter(c)
	return c:IsCode(511004117) and c:IsAbleToHand()
end

function s.destroymanticorefilter(c,e)
	return s.Mosiac(c) and c:IsDestructable(e) and c:IsFaceup()
end

function s.spsummonstalkerfilter(c,e,tp)
	return c:IsCode(50005633) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.spsummonbewdfilter(c,e,tp)
	return c:IsCode(CARD_BLUEEYES_W_DRAGON) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0
	and Duel.GetFlagEffect(tp,id+5)>0 and Duel.GetFlagEffect(tp,id+6)>0 and Duel.GetFlagEffect(tp,id+7)>0 and Duel.GetFlagEffect(tp,id+8)>0  then return end

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.armadillodiscard,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.materialadd,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.tributeD,tp,LOCATION_MZONE,0,1,nil,e,tp)

	local b3=Duel.GetFlagEffect(tp,id+3)==0
			and (Duel.GetFlagEffect(tp,id+6)==0 or Duel.GetFlagEffect(tp,id+7)==0 or
				(Duel.GetFlagEffect(tp,id+8)==0 and Duel.IsExistingMatchingCard(s.spsummonbewdfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,3,nil,e,tp)))
			and Duel.IsExistingMatchingCard(s.tributecheckfilter,tp,LOCATION_MZONE,0,1,nil,511002423)
			and Duel.IsExistingMatchingCard(s.tributecheckfilter,tp,LOCATION_MZONE,0,1,nil,511002424)
			and Duel.IsExistingMatchingCard(s.tributecheckfilter,tp,LOCATION_MZONE,0,1,nil,511002422)

	local b4=Duel.GetFlagEffect(tp,id+4)==0
			and Duel.GetFlagEffect(tp, id+9)>0
			and Duel.IsExistingMatchingCard(s.addvaccinationfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local b5=Duel.GetFlagEffect(tp,id+5)==0
			and Duel.IsExistingMatchingCard(s.destroymanticorefilter,tp,LOCATION_ONFIELD,0,1,nil,e)
			and Duel.IsExistingMatchingCard(s.spsummonstalkerfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)


	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4 or b5)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.armadillodiscard,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.materialadd,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.tributeD,tp,LOCATION_MZONE,0,1,nil,e,tp)

	local b3=Duel.GetFlagEffect(tp,id+3)==0
			and (Duel.GetFlagEffect(tp,id+6)==0 or Duel.GetFlagEffect(tp,id+7)==0 or
				(Duel.GetFlagEffect(tp,id+8)==0 and Duel.IsExistingMatchingCard(s.spsummonbewdfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,3,nil,e,tp)))
			and Duel.IsExistingMatchingCard(s.tributecheckfilter,tp,LOCATION_MZONE,0,1,nil,511002423)
			and Duel.IsExistingMatchingCard(s.tributecheckfilter,tp,LOCATION_MZONE,0,1,nil,511002424)
			and Duel.IsExistingMatchingCard(s.tributecheckfilter,tp,LOCATION_MZONE,0,1,nil,511002422)

	local b4=Duel.GetFlagEffect(tp,id+4)==0
			and Duel.GetFlagEffect(tp, id+9)>0
			and Duel.IsExistingMatchingCard(s.addvaccinationfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local b5=Duel.GetFlagEffect(tp,id+5)==0
			and Duel.IsExistingMatchingCard(s.destroymanticorefilter,tp,LOCATION_ONFIELD,0,1,nil,e)
			and Duel.IsExistingMatchingCard(s.spsummonstalkerfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,2)},
								  {b4,aux.Stringid(id,6)},
								  {b5,aux.Stringid(id,7)})
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
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
	local tc1=Duel.SelectMatchingCard(tp, s.armadillodiscard, tp, LOCATION_HAND, 0, 1,1,false,nil)
	if Duel.SendtoGrave(tc1, REASON_DISCARD) then
		local g=Duel.GetMatchingGroup(s.materialadd,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(sg, tp, REASON_RULE)
		Duel.ConfirmCards(1-tp, sg)
	end

	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local tc1=Duel.SelectMatchingCard(tp, s.tributeD, tp, LOCATION_MZONE, 0, 1,1,false,nil,e,tp)
	if tc1 and Duel.Release(tc1, REASON_COST) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tc2=Duel.SelectMatchingCard(tp, s.spsummondfilter, tp, LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE, 0, 1,1,false,nil,e,tp,tc1:GetFirst():GetOriginalCode())
		Duel.SpecialSummon(tc2, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)

	end


	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)

	local b1=Duel.GetFlagEffect(tp,id+6)==0
	local b2=Duel.GetFlagEffect(tp,id+7)==0
	local b3=Duel.GetFlagEffect(tp,id+8)==0 and Duel.IsExistingMatchingCard(s.spsummonbewdfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,3,nil,e,tp)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,3)},
								  {b2,aux.Stringid(id,4)},
								  {b3,aux.Stringid(id,5)})

	local rg=Group.CreateGroup()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local tc1=Duel.SelectMatchingCard(tp, s.tributecheckfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil,511002422)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local tc2=Duel.SelectMatchingCard(tp, s.tributecheckfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil,511002423)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local tc3=Duel.SelectMatchingCard(tp, s.tributecheckfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil,511002424)
	Group.AddCard(rg, tc1)
	Group.AddCard(rg, tc2)
	Group.AddCard(rg, tc3)
	Duel.Release(rg, REASON_COST)


	if op==1 then
		local g=Group.CreateGroup()
		local kglider=Duel.CreateToken(tp, 52824910)
		g:AddCard(kglider)
		local gbkglider=Duel.CreateToken(tp, 41002238)
		g:AddCard(gbkglider)
		local nkglider=Duel.CreateToken(tp, 45885288)
		g:AddCard(nkglider)

		Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
		Duel.RegisterFlagEffect(tp,id+6,0,0,0)

	elseif op==2 then
		local g=Group.CreateGroup()
		local xhead=Duel.CreateToken(tp, 62651957)
		g:AddCard(xhead)
		local yhead=Duel.CreateToken(tp, 65622692)
		g:AddCard(yhead)
		local zhead=Duel.CreateToken(tp, 64500000)
		g:AddCard(zhead)

		Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
		Duel.RegisterFlagEffect(tp,id+7,0,0,0)

	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp, s.spsummonbewdfilter, tp, LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK, 0, 3,3,false,nil,e,tp)
		Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
		Duel.RegisterFlagEffect(tp,id+8,0,0,0)

	end


	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp, s.addvaccinationfilter, tp, LOCATION_GRAVE|LOCATION_DECK, 0, 1,1,false,nil)
	Duel.SendtoHand(tc, tp, REASON_RULE)
	Duel.ConfirmCards(1-tp, tc)


	Duel.RegisterFlagEffect(tp,id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp, s.destroymanticorefilter, tp, LOCATION_ONFIELD, 0, 1,1,false,nil,e)
	if Duel.Destroy(tc, REASON_EFFECT) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp, s.spsummonstalkerfilter, tp, LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK, 0, 1,1,false,nil,e,tp)
		Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
	end
	Duel.RegisterFlagEffect(tp,id+5,0,0,0)
end
