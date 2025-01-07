--Deck Master - Deepsea Warrior
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

local CARD_DEEPSEA_WARRIOR=24128274


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
		e6:SetValue(RACE_REPTILE)
		Duel.RegisterEffect(e6,tp)


	end
	e:SetLabel(1)
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

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.encodeeffects(c, e, tp)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

end

local trapstoset={}
trapstoset[1]={43250041,56120475,62279055}
trapstoset[2]={44095762,47475363,20522190}
trapstoset[3]={10045474,97045737,40366667}
trapstoset[4]={93217231}


function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SSET)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsRace,1,false,nil,e:GetHandler(),RACE_REPTILE) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsRace,1,4,false,nil,e:GetHandler(),RACE_REPTILE)
	local ct=Duel.Release(g,REASON_COST)
	e:SetLabel(ct)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local num=e:GetLabel()

	local cardid=trapstoset[num][Duel.GetRandomNumber(1,#trapstoset[num])]
	local token=Duel.CreateToken(tp, cardid)
	Duel.SSet(tp,token,tp,false)
	local turn_ct=Duel.GetTurnCount()

	aux.DelayedOperation(token,PHASE_END,id+1,e,tp,
			function(ag)
				Duel.SendtoGrave(ag,REASON_EFFECT)
			end,
			function()
				return Duel.GetTurnCount()==turn_ct+1
			end,
			nil,2
		)
end



--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.CheckLPCost(tp, 1000)
            and Duel.GetLocationCount(tp, LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp, CARD_DEEPSEA_WARRIOR, nil, TYPE_EFFECT, 1600, 1800, 5, RACE_REPTILE, ATTRIBUTE_WATER)


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
    and Duel.IsPlayerCanSpecialSummonMonster(tp, CARD_DEEPSEA_WARRIOR, nil, TYPE_EFFECT, 1600, 1800, 5, RACE_REPTILE, ATTRIBUTE_WATER)
	





--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp, 1000)
	local deckmaster=Duel.CreateToken(tp, CARD_DEEPSEA_WARRIOR)
	if Duel.SpecialSummon(deckmaster, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP) then
		Card.RegisterFlagEffect(deckmaster, id, 0,0,0)
		s.encodeeffects(deckmaster,e,tp)
	end


	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end