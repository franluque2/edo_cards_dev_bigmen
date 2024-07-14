--Deck Master - Robotic Knight
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

local CARD_ROBOTIC_KNIGHT=44203504
local CARD_MACHINE_ASSEMBLY_LINE=25518020
function s.ismachineking(c)
    return c:IsCode(46700124, 19028307, 18891691, 89222931, 70406920, CARD_ROBOTIC_KNIGHT, 07359741)
end

function s.isheavymechsupport(c)
	return c:IsCode(23265594, 39890958)
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
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_PHASE+PHASE_END)
		e5:SetCondition(s.epcon)
		e5:SetOperation(s.epop)
        e5:SetCountLimit(1)
		Duel.RegisterEffect(e5,tp)

		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_CHANGE_RACE)
		e6:SetTargetRange(LOCATION_ALL, 0)
		e6:SetTarget(function (_, c) return (c:IsCode(40173854) or (not c:IsOriginalAttribute(ATTRIBUTE_EARTH))) end)
		e6:SetValue(RACE_MACHINE)
		Duel.RegisterEffect(e6,tp)

		local e7=e6:Clone()
		e7:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e7:SetValue(ATTRIBUTE_EARTH)
		Duel.RegisterEffect(e7, tp)


		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_CHAIN_SOLVED)
		e8:SetCondition(s.chaincon)
		e8:SetCountLimit(1)
		e8:SetOperation(s.chainop)
		Duel.RegisterEffect(e8, tp)


		local e9=Effect.CreateEffect(e:GetHandler())
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_SPSUMMON_SUCCESS)
		e9:SetCondition(s.fuscon)
		e9:SetCountLimit(1)
		e9:SetOperation(s.fusop)
		Duel.RegisterEffect(e9, tp)


		local e10=Effect.CreateEffect(e:GetHandler())
		e10:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e10:SetCode(EFFECT_DESTROY_REPLACE)
		e10:SetTarget(s.desreptg)
		e10:SetValue(s.desrepval)
		e10:SetOperation(s.desrepop)
		Duel.RegisterEffect(e10,tp)


		local e11=Effect.CreateEffect(e:GetHandler())
		e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e11:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e11:SetCondition(s.spcon)
		e11:SetOperation(s.spop)
        e11:SetCountLimit(1)
		Duel.RegisterEffect(e11,tp)


	end
	e:SetLabel(1)
end

function s.addvanillafilter(c)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.fumachineassemblyfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
		and Duel.IsExistingMatchingCard(s.addvanillafilter, tp, LOCATION_GRAVE|LOCATION_REMOVED, 0, 1, nil)
		and Duel.GetCounter(tp, LOCATION_ONFIELD, 0, 0x1d)>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
		Duel.Hint(HINT_CARD, tp, id)
		local g=Duel.GetMatchingGroup(s.addvanillafilter, tp, LOCATION_REMOVED|LOCATION_GRAVE, 0, nil)
		local num=Duel.GetCounter(tp, LOCATION_ONFIELD, 0, 0x1d)
		if num>#g then num=#g end
		local num_table={}
		for i = 1, num, 1 do
			num_table[i]=i
		end
		local torem=Duel.AnnounceNumber(tp, num_table)
		Duel.RemoveCounter(tp, LOCATION_ONFIELD, 0, 0x1d, torem, REASON_COST)

		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local tohand=Duel.SelectMatchingCard(tp, s.addvanillafilter, tp, LOCATION_REMOVED|LOCATION_GRAVE, 0, torem, torem, false, nil)
		if tohand and Duel.SendtoHand(tohand, tp, REASON_RULE) then
			Duel.ConfirmCards(1-tp, tohand)
		end
	end
end


function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(CARD_MACHINE_ASSEMBLY_LINE) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:GetCounter(0x1d)>1
end
function s.desfilter(c,e,tp)
	return c:IsCode(47660516) and c:IsAbleToRemove()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end

function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 3)) then
		e:SetLabelObject(eg:Filter(s.repfilter, nil, tp))
		return true
	else return false end
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	for tc in g:Iter() do
		tc:RemoveCounter(tp,0x1d,2,REASON_EFFECT)
	end
end




function s.machinefusionfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end

function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and eg:IsExists(s.machinefusionfilter, 1, nil)
	
end
	
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp, id+6, RESET_PHASE+PHASE_END, 0, 0)
end


function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
local rc=re:GetHandler()
	local loc=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION)
	return (re:GetActiveType()==TYPE_CONTINUOUS+TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and (loc&LOCATION_SZONE)==LOCATION_SZONE and rc:IsCode(84797028))
end

function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp, id+5, RESET_PHASE+PHASE_END, 0, 0)
end

function s.toremfilter(c)
    return c:GetFlagEffect(id)>0
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.toremfilter, tp, LOCATION_ALL, LOCATION_ALL, 1, nil)
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)

        local torem=Duel.GetMatchingGroup(s.toremfilter, tp, LOCATION_ALL, LOCATION_ALL, nil)
		Duel.RemoveCards(torem)
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	local labtank=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 99551425)
	for tc in labtank:Iter() do
		Fusion.AddProcMix(tc, true, true, 08471389, aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE))
	end

	local Bugroth=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 40173854)
	for tc in Bugroth:Iter() do
		Fusion.AddProcMix(tc, true, true, 58314394, aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE))
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.encodeeffects(c, e, tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tftg)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
	e3:SetCost(s.tftcost)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

function s.sendmachinefilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sendmachinefilter,tp,LOCATION_HAND,0,1,nil) end
	local cg=Duel.DiscardHand(tp,s.sendmachinefilter,1,99,REASON_COST+REASON_DISCARD,nil)
	e:SetLabel(cg)
end

function s.fumachineassemblyfilter(c)
	return c:IsCode(CARD_MACHINE_ASSEMBLY_LINE) and c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sendmachinefilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*100)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.Damage(1-p,e:GetLabel()*100,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.fumachineassemblyfilter, tp, LOCATION_ONFIELD, 0, 1, nil) then
		local g=Duel.GetMatchingGroup(s.fumachineassemblyfilter, tp, LOCATION_ONFIELD, 0, nil)
		for tc in g:Iter() do
			tc:AddCounter(0x1d,e:GetLabel())
		end
	end

end


function s.tffilter(c,tp)
	return c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS) and c:IsCode(CARD_MACHINE_ASSEMBLY_LINE) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end

function s.discardmachinefilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsDiscardable(REASON_COST)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tffilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,nil,tp) end
end
function s.tftcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.discardmachinefilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.discardmachinefilter,1,1,REASON_DISCARD+REASON_COST)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tffilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)

		local g=Duel.GetMatchingGroup(aux.FaceupFilter(s.ismachineking), tp, LOCATION_ONFIELD|LOCATION_GRAVE, 0, nil)
		local num=Group.GetClassCount(g, Card.GetCode)
		tc:AddCounter(0x1d,num)

	end
end

function s.val(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*300
end

function s.addfilter(c)
	return (s.ismachineking(c) or s.isheavymechsupport(c) or c:IsCode(511000635)) and c:IsAbleToHand()
end

function s.equipmechfilter(c, ec)
	return s.isheavymechsupport(c) and c:CheckUnionTarget(ec) and aux.CheckUnionEquip(c,ec)
end
function s.toequipfilter(c,tp)
	return Duel.IsExistingMatchingCard(s.equipmechfilter,tp,LOCATION_GRAVE,0,1,nil,c)
end
function s.tosummonanymkingfilter(c,e,tp)
	return s.ismachineking(c) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP)
end
function s.tributefilter(c, code)
	return c:IsCode(code) and c:IsReleasableByEffect()
end

function s.spsummonmkingfilter(c,e,tp)
	return c:IsCode(46700124) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP)
end

function s.spsummonperfkingfilter(c,e,tp)
	return c:IsCode(18891691) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP)
end
--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.CheckLPCost(tp, 1000)
            and Duel.GetLocationCount(tp, LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp, CARD_ROBOTIC_KNIGHT, nil, TYPE_NORMAL, 1600, 1800, 4, RACE_MACHINE, ATTRIBUTE_FIRE)
	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.GetFlagEffect(tp, id+5)>0
			and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.GetFlagEffect(tp, id+6)>0
			and Duel.IsExistingMatchingCard(s.toequipfilter,tp,LOCATION_MZONE,0,1,nil, tp)


	local b4=Duel.GetFlagEffect(tp, id+4)==0
			and Duel.IsExistingMatchingCard(s.tributefilter,tp,LOCATION_MZONE,0,1,nil, 70406920)
			and Duel.IsExistingMatchingCard(s.tosummonanymkingfilter, tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,nil,e,tp)

	local b5=Duel.GetFlagEffect(tp, id+4)==0
		and Duel.GetFlagEffect(tp, id+7)==0
		and Duel.IsExistingMatchingCard(s.tributefilter,tp,LOCATION_ONFIELD,0,1,nil, 89222931)
		and Duel.IsExistingMatchingCard(s.spsummonmkingfilter, tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)

	local b6=Duel.GetFlagEffect(tp, id+4)==0
			and Duel.GetFlagEffect(tp, id+8)==0
			and Duel.IsExistingMatchingCard(s.tributefilter,tp,LOCATION_ONFIELD,0,1,nil, 46700124)
			and Duel.IsExistingMatchingCard(s.spsummonperfkingfilter, tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)



--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4 or b5 or b6)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

	local b1=Duel.GetFlagEffect(tp,id+1)==0
	and Duel.CheckLPCost(tp, 1000)
	and Duel.GetLocationCount(tp, LOCATION_MZONE)>0
	and Duel.IsPlayerCanSpecialSummonMonster(tp, CARD_ROBOTIC_KNIGHT, nil, TYPE_NORMAL, 1600, 1800, 4, RACE_MACHINE, ATTRIBUTE_FIRE)
	local b2=Duel.GetFlagEffect(tp,id+2)==0
	and Duel.GetFlagEffect(tp, id+5)>0
	and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+3)==0
	and Duel.GetFlagEffect(tp, id+6)>0
	and Duel.IsExistingMatchingCard(s.toequipfilter,tp,LOCATION_MZONE,0,1,nil, tp)

	local b4=Duel.GetFlagEffect(tp, id+4)==0
	and Duel.IsExistingMatchingCard(s.tributefilter,tp,LOCATION_MZONE,0,1,nil, 70406920)
	and Duel.IsExistingMatchingCard(s.tosummonanymkingfilter, tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,nil,e,tp)

	local b5=Duel.GetFlagEffect(tp, id+4)==0
	and Duel.GetFlagEffect(tp, id+7)==0
	and Duel.IsExistingMatchingCard(s.tributefilter,tp,LOCATION_ONFIELD,0,1,nil, 89222931)
	and Duel.IsExistingMatchingCard(s.spsummonmkingfilter, tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)

	local b6=Duel.GetFlagEffect(tp, id+4)==0
	and Duel.GetFlagEffect(tp, id+8)==0
	and Duel.IsExistingMatchingCard(s.tributefilter,tp,LOCATION_ONFIELD,0,1,nil, 46700124)
	and Duel.IsExistingMatchingCard(s.spsummonperfkingfilter, tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)






--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,8)},
								  {b3,aux.Stringid(id,9)},
								  {b4,aux.Stringid(id,5)},
								  {b5,aux.Stringid(id,6)},
								  {b6,aux.Stringid(id,7)})
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
	elseif op==5 then
		s.operation_for_res5(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp, 1000)
	local deckmaster=Duel.CreateToken(tp, CARD_ROBOTIC_KNIGHT)
	if Duel.SpecialSummon(deckmaster, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP) then
		Card.RegisterFlagEffect(deckmaster, id, 0,0,0)
		s.encodeeffects(deckmaster,e,tp)
	end


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

--add
function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local toadd=Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_GRAVE|LOCATION_DECK, 0, 1,1,false,nil)
	if toadd and Duel.SendtoHand(toadd, tp, REASON_RULE) then
		Duel.ConfirmCards(1-tp, toadd)
	end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
--equip
function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
	local toequip=Duel.SelectMatchingCard(tp, s.toequipfilter, tp, LOCATION_MZONE, 0, 1,1,false,nil, tp)
	if toequip then
		local tc=toequip:GetFirst()
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
		local equippedcard=Duel.SelectMatchingCard(tp, s.equipmechfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil, tc):GetFirst()
		if equippedcard and Duel.Equip(tp,equippedcard,tc) then
			aux.SetUnionState(equippedcard)
		end
	
	end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
-- 30k
function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local totrib=Duel.SelectMatchingCard(tp, s.tributefilter, tp, LOCATION_MZONE, 0, 1,1,false,nil,70406920)
	if totrib and Duel.Release(totrib, REASON_COST) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tosum=Duel.SelectMatchingCard(tp, s.tosummonanymkingfilter, tp, LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK, 0, 1,1,false,nil,e,tp)
		if tosum then
			Duel.SpecialSummon(tosum, SUMMON_TYPE_SPECIAL, tp,tp, false,false, POS_FACEUP)
		end
	end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
--prototype
function s.operation_for_res4(e,tp,eg,ep,ev,re,r,rp)

	local totrib=Duel.SelectMatchingCard(tp, s.tributefilter, tp, LOCATION_MZONE, 0, 1,1,false,nil,89222931) 
	if totrib and Duel.Release(totrib, REASON_COST) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tosum=Duel.SelectMatchingCard(tp, s.spsummonmkingfilter, tp, LOCATION_HAND|LOCATION_DECK, 0, 1,1,false,nil,e,tp)
		if tosum then
			Duel.SpecialSummon(tosum, SUMMON_TYPE_SPECIAL, tp,tp, false,false, POS_FACEUP)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(RACE_MACHINE)
			e2:SetTargetRange(0,LOCATION_MZONE)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	Duel.RegisterFlagEffect(tp,id+7,0,0,0)
end
-- mk
function s.operation_for_res5(e,tp,eg,ep,ev,re,r,rp)

	local totrib=Duel.SelectMatchingCard(tp, s.tributefilter, tp, LOCATION_MZONE, 0, 1,1,false,nil,46700124)
	if totrib and Duel.Release(totrib, REASON_COST) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tosum=Duel.SelectMatchingCard(tp, s.spsummonperfkingfilter, tp, LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK, 0, 1,1,false,nil,e,tp)
		if tosum then
			Duel.SpecialSummon(tosum, SUMMON_TYPE_SPECIAL, tp,tp, false,false, POS_FACEUP)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(RACE_MACHINE)
			e2:SetTargetRange(0,LOCATION_MZONE)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end


	--sets the opd
	Duel.RegisterFlagEffect(tp,id+4,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	Duel.RegisterFlagEffect(tp,id+8,0,0,0)
end
