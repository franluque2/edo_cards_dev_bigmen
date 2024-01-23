--We CAN:Do it Live! A Fiery Concert!
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

        local c=e:GetHandler()
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCountLimit(1)
        e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
        e2:SetCondition(s.adcon)
        e2:SetOperation(s.adop)
        Duel.RegisterEffect(e2,tp)

		local e12=Effect.CreateEffect(e:GetHandler())
        e12:SetType(EFFECT_TYPE_FIELD)
        e12:SetCode(EFFECT_FUSION_SUBSTITUTE)
        e12:SetTargetRange(LOCATION_MZONE,0)
        e12:SetTarget(function(_,c)  return c:IsCode(CARD_CAN_D) end)
		e12:SetValue(s.subval)
		Duel.RegisterEffect(e12,tp)

		local e13=Effect.CreateEffect(e:GetHandler())
		e13:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e13:SetCode(EFFECT_DESTROY_REPLACE)
		e13:SetTarget(s.desreptg)
		e13:SetValue(s.desrepval)
		e13:SetOperation(s.desrepop)
		Duel.RegisterEffect(e13,tp)

		local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_CONTINUOUS)
        e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e3:SetCode(EVENT_ADJUST)
        e3:SetCondition(s.adjustArtCon)
        e3:SetOperation(s.adjustartop)
        Duel.RegisterEffect(e3,tp)

		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_BATTLE_DAMAGE)
		e6:SetCondition(s.reccon2)
		e6:SetOperation(s.recop2)
		Duel.RegisterEffect(e6,tp)



	end
	e:SetLabel(1)
end


function s.fupsychicfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHIC) and c:IsControler(tp)
end

function s.reccon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:IsExists(s.fupsychicfilter,1,nil,tp,tp) and Duel.GetFlagEffect(tp, id+4)==0
end
function s.recop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_CARD,tp,s.getpicture(tp))
		if Duel.GetFlagEffect(tp, id+10)==0 then
			Duel.RegisterFlagEffect(tp, id+10, 0,0,0,Duel.GetBattleDamage(1-tp)/2)
		else
			local dam=Duel.GetFlagEffectLabel(tp,id+10)
			dam=dam+Duel.GetBattleDamage(1-tp)/2
		end
		Duel.RegisterFlagEffect(tp, id+4, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
    end
end

function s.adjustArtCon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetLP(tp)<=1000 and Duel.GetLP(tp)>0 and Duel.GetFlagEffect(tp, id+5)==0) or (Duel.GetLP(tp)>1000 and Duel.GetFlagEffect(tp, id+5)~=0)
end

function s.adjustartop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))

	if (Duel.GetLP(tp)<=1000 and Duel.GetLP(tp)>0 and Duel.GetFlagEffect(tp, id+5)==0) then
		e:GetHandler():Recreate(id+1)
		Duel.Hint(HINT_SKILL_REMOVE,tp,id)
		Duel.Hint(HINT_SKILL_FLIP,tp,(id+1)|(1<<32))
		Duel.Hint(HINT_SKILL,tp,id+1)
		Duel.RegisterFlagEffect(tp, id+5, 0, 0, 0)
	
	else
		e:GetHandler():Recreate(id)
		Duel.Hint(HINT_SKILL_REMOVE,tp,id)
		Duel.Hint(HINT_SKILL_FLIP,tp,(id)|(1<<32))
		Duel.Hint(HINT_SKILL,tp,id)
		Duel.ResetFlagEffect(tp, id+5)

	end

end


function s.repfilter(c,tp)
	return c:IsControler(tp) and (c:IsRace(RACE_PSYCHIC) or c:IsRace(RACE_OMEGAPSYCHIC)) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsLevelAbove(7)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:GetReasonPlayer()~=tp
end
function s.desfilter(c,e,tp)
	return c:IsAbleToRemoveAsCost()
end
function s.cfilter(c)
	return c:IsOriginalCode(81632512) and c:IsAbleToRemoveAsCost()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and g:IsExists(s.desfilter,1,nil,e,tp) end
	if Duel.SelectYesNo(tp,aux.Stringid(id, 5)) then
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


function s.subval(e,c)
    return not c:ListsCodeAsMaterial(CARD_CAN_D)
end

local cards_to_summon={160205053,160428037,160401006,160428027, 160016025}
local cards_to_add={160005039,160005040,160011054,81632429,81632512}

local summons={}
summons[0]=Group.CreateGroup()
summons[1]=Group.CreateGroup()


local adds={}
adds[0]=Group.CreateGroup()
adds[1]=Group.CreateGroup()


function s.filltables()
    if #summons[0]==0 then
        for i, v in pairs(cards_to_summon) do
            local token1=Duel.CreateToken(0, v)
            summons[0]:AddCard(token1)
            local token2=Duel.CreateToken(1, v)
            summons[1]:AddCard(token2)


        end

        for i, v in pairs(cards_to_add) do
            local token1=Duel.CreateToken(0, v)
            adds[0]:AddCard(token1)

            local token2=Duel.CreateToken(1, v)
            adds[1]:AddCard(token2)

        end

    end
end

function s.getpicture(tp)
	if Duel.GetLP(tp)>1000 then
		return id
	else
		return id+1
	end
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

local candarts={160005002,160401004,160446013}
function s.getcanDArt()
	return candarts[Duel.GetRandomNumber(1,#candarts)]
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_CARD,tp,s.getpicture(tp))
        local cand=Duel.CreateToken(tp,s.getcanDArt())
        Duel.SendtoHand(cand, tp, REASON_RULE)
		
		--debugging
		--Duel.RegisterFlagEffect(tp, id+10, 0, 0, 0, 1000)

    end

    if Duel.GetFlagEffect(tp, id+10)>0 then
        Duel.Hint(HINT_CARD,tp,s.getpicture(tp))
        local candy=Duel.CreateToken(tp,81632512)
        Duel.SendtoHand(candy, tp, REASON_RULE)
		candy:RegisterFlagEffect(id, 0, 0, 0)
        candy:SetFlagEffectLabel(id, Duel.GetFlagEffectLabel(tp,id+10))
		Duel.ResetFlagEffect(tp, id+10)
    end
end






function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,s.getpicture(tp))

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	s.filltables()
end

function s.candfilter(c)
	return c:IsCode(CARD_CAN_D) and c:IsFaceup()
end


function s.sendandfilter(c)
	return s.candfilter(c) and c:IsAbleToGraveAsCost()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0  then return end

	local psychcount=Duel.GetMatchingGroupCount(Card.IsRace, tp, LOCATION_GRAVE, 0, nil, RACE_PSYCHIC)

	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.sendandfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.CheckLPCost(tp, 500)
						and Duel.IsPlayerCanSpecialSummon(tp)
						and #summons[tp]>0
	local b2=Duel.GetFlagEffect(tp,id+3)==0
		and Duel.IsExistingMatchingCard(s.sendandfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsPlayerCanDiscardDeckAsCost(tp, 1)
		and #adds[tp]>0

	local b3=psychcount>9 and Duel.CheckLPCost(tp, psychcount*200)


	return aux.CanActivateSkill(tp) and (b1 or b2 or b3)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,s.getpicture(tp))
	--Boolean check for effect 1:

--copy the bxs from above

local psychcount=Duel.GetMatchingGroupCount(Card.IsRace, tp, LOCATION_GRAVE, 0, nil, RACE_PSYCHIC)

local b1=Duel.GetFlagEffect(tp,id+2)==0
		and Duel.IsExistingMatchingCard(s.sendandfilter,tp,LOCATION_ONFIELD,0,1,nil)
					and Duel.CheckLPCost(tp, 500)
					and Duel.IsPlayerCanSpecialSummon(tp)
					and #summons[tp]>0
local b2=Duel.GetFlagEffect(tp,id+3)==0
	and Duel.IsExistingMatchingCard(s.sendandfilter,tp,LOCATION_ONFIELD,0,1,nil)
	and Duel.IsPlayerCanDiscardDeckAsCost(tp, 1)
	and #adds[tp]>0

local b3=psychcount>9 and Duel.CheckLPCost(tp, psychcount*200)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)},
								  {b2,aux.Stringid(id,3)},
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
	Duel.PayLPCost(tp, 500)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local cand=Duel.SelectMatchingCard(tp, s.sendandfilter, tp, LOCATION_ONFIELD, 0, 1,1,false,nil)
	if cand and Duel.SendtoGrave(cand, REASON_COST) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tosum=Group.Select(summons[tp], tp, 1,1,false,nil)
		if tosum then
			Duel.SpecialSummon(tosum, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
			Group.RemoveCard(summons[tp], tosum)
		end
	end


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

	Duel.DiscardDeck(tp, 1, REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tohand=Group.Select(adds[tp], tp, 1,1,false,nil)
		if tohand then
			Duel.SendtoHand(tohand, tp, REASON_RULE)
			Duel.ConfirmCards(1-tp, tohand)
			Group.RemoveCard(adds[tp], tohand)
		end
	--sets the opd
	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	local psychcount=Duel.GetMatchingGroupCount(Card.IsRace, tp, LOCATION_GRAVE, 0, nil, RACE_PSYCHIC)
	Duel.PayLPCost(tp, psychcount*200)

	local climax=Duel.CreateToken(tp, 160201038)
	Duel.SendtoHand(climax, tp, REASON_RULE)
	Duel.ConfirmCards(1-tp, climax)
	--sets the opd
end
