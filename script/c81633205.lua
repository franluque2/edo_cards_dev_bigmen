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
    return c:IsCode(46700124, 19028307, 188891691, 89222931, 70406920, CARD_ROBOTIC_KNIGHT, 07359741)
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


	end
	e:SetLabel(1)
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


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
	local cg=Duel.DiscardHand(tp,Card.IsDiscardable,1,99,REASON_COST+REASON_DISCARD,nil)
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
	end
end

function s.val(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*300
end

function s.addfilter(c)
	return (s.ismachineking(c) or c:isheavymechsupport(c) or c:IsCode(511000635)) and c:IsAbleToHand()
end

function s.equipmechfilter(c, ec)
	return s.isheavymechsupport(c) and c:CheckUnionTarget(ec) and aux.CheckUnionEquip(c,ec)
end
function s.toequipfilter(c,tp)
	return Duel.IsExistingMatchingCard(s.equipmechfilter,tp,LOCATION_GRAVE,0,1,nil,c)
end

function s.tributefilter(c, code)
	return c:IsCode(code) and c:IsReleasableByEffect()
end
--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
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


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
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



--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)},
								  {b3,aux.Stringid(id,1)},
								  {b4,aux.Stringid(id,1)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	elseif op==4 then
		s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)

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


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+3,0,0,0)
end

function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
end
