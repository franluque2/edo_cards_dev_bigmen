--Destroyer of Rush Duels
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
local CHOSEN_LEGEND={}
local SKILL_IMG={}
CHOSEN_LEGEND[0]=27288416 --defaults to mokey mokey in case weird shit happens
CHOSEN_LEGEND[1]=27288416 --defaults to mokey mokey in case weird shit happens
SKILL_IMG[0]=id
SKILL_IMG[1]=id

local added_cards={}
added_cards[0]={}
added_cards[1]={}

function s.has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
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

        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e5:SetCode(EFFECT_DOUBLE_TRIBUTE)
        e5:SetValue(s.effcon)
        e5:SetTarget(aux.TargetBoolFunction())
        e5:SetTargetRange(LOCATION_MZONE,0)
        Duel.RegisterEffect(e5,tp)

		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_PHASE+PHASE_END)
		e6:SetCondition(s.epcon)
		e6:SetOperation(s.epop)
        e6:SetCountLimit(1)
		Duel.RegisterEffect(e6,tp)


	end
	e:SetLabel(1)
end

function s.banishlegendfilter(c)
	return c:IsLegend() and c:IsAbleToRemove()
end

function s.supcardfilter(c)
	return c:IsSpellTrap() and c:IsAbleToRemove() and c:ListsCode(CHOSEN_LEGEND[c:GetControler()]) and c:CheckActivateEffect(false,true,false)~=nil
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.fulegendfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and Duel.GetTurnPlayer()==tp and Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0
		and Duel.IsExistingMatchingCard(s.banishlegendfilter, tp, LOCATION_GRAVE, 0, 3, nil) and Duel.IsExistingMatchingCard(s.supcardfilter, tp, LOCATION_GRAVE, 0, 1, nil)
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp, aux.Stringid(SKILL_IMG[tp], 4)) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
		local tobanish=Duel.SelectMatchingCard(tp, s.banishlegendfilter, tp, LOCATION_GRAVE, 0, 3,3,false,nil)
		if Duel.Remove(tobanish, POS_FACEUP, REASON_COST) then
			Duel.BreakEffect()
			local tc=Duel.SelectMatchingCard(tp, s.supcardfilter, tp, LOCATION_GRAVE, 0, 1,1,false,nil):GetFirst()

			local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
			if not te then return end
			local tg=te:GetTarget()
			local op=te:GetOperation()
			if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
			Duel.BreakEffect()
			tc:CreateEffectRelation(te)
			Duel.BreakEffect()
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			for etc in aux.Next(g) do
				etc:CreateEffectRelation(te)
			end
			if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
			tc:ReleaseEffectRelation(te)
			for etc in aux.Next(g) do
				etc:ReleaseEffectRelation(te)
			end
			Duel.BreakEffect()
			Duel.Remove(tc, POS_FACEUP, REASON_RULE)
		end
	end

end


--return Duel.GetTurnPlayer()==tp and Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0

function s.effcon(e,c)
	return c:IsLegend() and c:IsLevelAbove(7) and c:IsType(TYPE_NORMAL)
end


function s.lowlevellegendfilter(c) 
    return c:IsLegend() and c:IsLevelBelow(4) and c:IsType(TYPE_NORMAL)
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

    s.taglegends(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.taglegends(e,tp,eg,ep,ev,re,r,rp)
    local legends=Duel.GetMatchingGroup(s.lowlevellegendfilter, tp, LOCATION_ALL, 0, nil)

    for tc in legends:Iter() do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
        e1:SetValue(s.effcon)
        tc:RegisterEffect(e1)
    end

end


function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)
    local chosen_id=Duel.SelectEffect(1, {1,aux.Stringid(id,0)},
                        {1,aux.Stringid(id,1)},
                        {1,aux.Stringid(id,2)},
                        {1,aux.Stringid(id,3)})

    if chosen_id==1 then
        CHOSEN_LEGEND[tp]=CARD_DARK_MAGICIAN
    elseif chosen_id==2 then
        CHOSEN_LEGEND[tp]=CARD_BLUEEYES_W_DRAGON
    elseif chosen_id==3 then
        CHOSEN_LEGEND[tp]=CARD_REDEYES_B_DRAGON
    elseif chosen_id==4 then
        CHOSEN_LEGEND[tp]=CARD_SUMMONED_SKULL
    end
    
    SKILL_IMG[tp]=SKILL_IMG[tp]+chosen_id

    Duel.Hint(HINT_SKILL_REMOVE,tp,id)
    Duel.Hint(HINT_SKILL_FLIP,tp,(SKILL_IMG[tp])|(1<<32))
    Duel.Hint(HINT_SKILL,tp,SKILL_IMG[tp])

end

function s.fulegendfilter(c)
    return c:IsCode(CHOSEN_LEGEND[c:GetControler()]) and c:IsFaceup()
end

function s.addlegendsupfilter(c)
    return c:IsSpellTrap() and c:ListsCode(CHOSEN_LEGEND[c:GetControler()]) and c:IsAbleToHand()  and not s.has_value(added_cards[c:GetControler()], c:GetCode())
end

--dm

function s.fumagvalkfilter(c)
	return c:IsCode(80304126) and c:IsFaceup()

end

function s.addvalkupfilter(c)
    return c:IsSpellTrap() and c:ListsCode(80304126) and c:IsAbleToHand()  and not s.has_value(added_cards[c:GetControler()], c:GetCode())
end

function s.recovervalkfilter(c)
    return c:IsCode(80304126) and c:IsAbleToHand()
end

function s.special_legend_dm_filter(c,e,tp)
	return c:IsLegend() and c:IsAttack(2500) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false,POS_FACEUP) and c:IsType(TYPE_NORMAL)
end

function s.dmgfilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN_GIRL) and c:IsFaceup()
end

--bewd
function s.fu_dragon_normal_filter(c)
	return c:IsFaceup() and c:IsLegend() and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(7) and c:IsType(TYPE_NORMAL)
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp,id+3)>0 and Duel.GetFlagEffect(tp,id+4)>0  and Duel.GetFlagEffect(tp,id+5)>0 and Duel.GetFlagEffect(tp,id+6)>0 
        and Duel.GetFlagEffect(tp,id+7)>0 and Duel.GetFlagEffect(tp,id+8)>0 and Duel.GetFlagEffect(tp,id+9)>0  then return end

	local b1=Duel.GetFlagEffect(tp,id+1)==0
		and Duel.IsExistingMatchingCard(s.fulegendfilter,tp,LOCATION_ONFIELD,0,1,nil)
					and Duel.IsExistingMatchingCard(s.addlegendsupfilter,tp,LOCATION_DECK,0,1,nil)

						--DM
	local b2=Duel.GetFlagEffect(tp,id+2)==0
		and Duel.IsExistingMatchingCard(s.fumagvalkfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.addvalkupfilter,tp,LOCATION_DECK,0,1,nil)

    local b3=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.dmgfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.special_legend_dm_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)

						--BEWD
	local b4=Duel.GetFlagEffect(tp,id+4)==0
			and Duel.IsExistingMatchingCard(s.fu_dragon_normal_filter,tp,LOCATION_ONFIELD,0,1,nil)

    local b5=Duel.GetFlagEffect(tp,id+5)==0
			and Duel.IsExistingMatchingCard(s.fulegendfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addlegendsupfilter,tp,LOCATION_DECK,0,1,nil)

						--REBD
	local b6=Duel.GetFlagEffect(tp,id+6)==0
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)

    local b7=Duel.GetFlagEffect(tp,id+7)==0
			and Duel.IsExistingMatchingCard(s.fulegendfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.addlegendsupfilter,tp,LOCATION_DECK,0,1,nil)

						--SUMM_SKULL
	local b8=Duel.GetFlagEffect(tp,id+8)==0
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)

	local b9=Duel.GetFlagEffect(tp,id+9)==0
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4 or b5 or b6 or b7 or b8 or b9)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,SKILL_IMG[tp])
	--Boolean check for effect 1:

--copy the bxs from above

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.icustomfilter,tp,LOCATION_ONFIELD,0,1,nil)
						and Duel.IsExistingMatchingCard(s.conttrapfiler,tp,LOCATION_DECK,0,1,nil)


	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
