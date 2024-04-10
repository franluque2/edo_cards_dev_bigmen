--Mark of the Condor
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

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_LEAVE_FIELD)
		e2:SetCondition(s.flipcon3)
		e2:SetOperation(s.flipop3)
		Duel.RegisterEffect(e2,tp)


	end
	e:SetLabel(1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.activate_field(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 41181774)
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
--at the start of the duel, activate 1 field spell from your hand or deck
function s.activate_field(e,tp,eg,ep,ev,re,r,rp)
	local field=Duel.SelectMatchingCard(tp,s.field_filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if #field>0 then
		Duel.ActivateFieldSpell(field:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
	end
end


function s.walkerfilter(c,tp)
	return ((c:IsCode(71821687) and not (Duel.GetFlagEffect(tp, id+6)>0) or
	 (c:IsCode(17315396) and not (Duel.GetFlagEffect(tp, id+7)>0)))) and c:IsAbleToHand()
end

function s.monsterfilter(c)
	return c:IsFaceup() and c:HasLevel()
end

function s.wiracocha_rasca_filter(c)
	return c:IsCode(41181774) and c:IsFaceup()
end

function s.limbo_monster_filter(c,e,tp)
	return (c:GetFlagEffect(id)>0) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
end

function s.high_level_filter(c)
	return c:HasLevel() and c:IsLevelAbove(5) and c:IsFaceup()
end

function s.supay_ascator_filter(c)
	return (c:IsCode(78275321) or c:IsCode(78552773)) and c:IsAbleToDeck()
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+3)>0 and
	 	Duel.GetFlagEffect(tp, id+4)>0 then return end
	--Boolean checks for the activation condition: b1, b2, b3, b4
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.walkerfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp)
			and (Duel.GetFlagEffect(tp, id+6)==0 or Duel.GetFlagEffect(tp, id+7)==0)

	-- local b2=Duel.GetFlagEffect(ep,id+2)==0
	-- 		and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.wiracocha_rasca_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0

	local b4=Duel.GetFlagEffect(tp, id+4)==0
		and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0


	return aux.CanActivateSkill(tp) and (b1 or b3 or b4)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.walkerfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp)
			and (Duel.GetFlagEffect(tp, id+6)==0 or Duel.GetFlagEffect(tp, id+7)==0)

	-- local b2=Duel.GetFlagEffect(ep,id+2)==0
	-- 		and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

	local b3=Duel.GetFlagEffect(tp,id+3)==0
			and Duel.IsExistingMatchingCard(s.wiracocha_rasca_filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0

	local b4=Duel.GetFlagEffect(tp, id+4)==0
		and Duel.IsExistingMatchingCard(s.high_level_filter, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b3,aux.Stringid(id,2)},
								  {b4,aux.Stringid(id,4)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		-- s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
		s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	end
end

--op=0, Once per turn, you can add 1 "Ascator, Dawnwalker" or "Supay, Duskwalker" from your Deck or GY to your hand,
 -- then you can shuffle all "Supay" and "Fire Ant Ascator" from your GY into the deck, and if you do,
	--  add 1 "Eathbound Linewalker" to your hand from outside the duel.
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.walkerfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
			if g:GetFirst():GetCode() ==71821687 then
				Duel.RegisterFlagEffect(tp,id+6,0,0,0)
		elseif g:GetFirst():GetCode()==17315396 then
			Duel.RegisterFlagEffect(tp,id+7,0,0,0)
		end
		Duel.SendtoHand(g, tp, REASON_EFFECT)
		local g2=Duel.GetMatchingGroup(s.supay_ascator_filter, tp, LOCATION_GRAVE, 0, nil)
		if #g2>0 then
			if Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			 Duel.SendtoDeck(g2, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
			end
		end
	end
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end

--op=1, Once per turn, You can target 1 monster you control, and declare a level from 1-11,
-- until the end of this turn, that monster becomes that level, then you can make it become a dark tuner monster.
-- function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
-- 	local tc=Duel.SelectMatchingCard(tp,s.monsterfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
-- 	if tc then
-- 		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
-- 		local lvl=Duel.AnnounceLevel(tp,1,11)
-- 		local e1=Effect.CreateEffect(e:GetHandler())
-- 		e1:SetType(EFFECT_TYPE_SINGLE)
-- 		e1:SetCode(EFFECT_CHANGE_LEVEL)
-- 		e1:SetValue(lvl)
-- 		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
-- 		tc:RegisterEffect(e1)
-- 		if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
-- 			local e3=e1:Clone()
-- 			e3:SetCode(EFFECT_ADD_TYPE)
-- 			e3:SetValue(TYPE_TUNER)
-- 			tc:RegisterEffect(e3)
-- 			local e4=e1:Clone()
-- 			e4:SetCode(EFFECT_ADD_SETCODE)
-- 			e4:SetValue(0x600)
-- 			tc:RegisterEffect(e4)
-- 			local e5=Effect.CreateEffect(e:GetHandler())
-- 			e5:SetType(EFFECT_TYPE_SINGLE)
-- 			e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
-- 			e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
-- 			e5:SetValue(s.synlimit)
-- 			e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
-- 			tc:RegisterEffect(e5)
-- 		end
-- 	end
-- 	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
-- end

-- function s.synlimit(e,c)
-- 	if not c then return false end
-- 	return not c:IsSetCard(0x601)
-- end

function ripairs(t)
    -- Try not to use break when using this function;
    -- it may cause the array to be left with empty slots
    local ci = 0
    local remove = function()
        t[ci] = nil
    end
    return function(t, i)
        --print("I", table.concat(array, ','))
        i = i+1
        ci = i
        local v = t[i]
        if v == nil then
            local rj = 0
            for ri = 1, i-1 do
                if t[ri] ~= nil then
                    rj = rj+1
                    t[rj] = t[ri]
                    --print("R", table.concat(array, ','))
                end
            end
            for ri = rj+1, i do
                t[ri] = nil
            end
            return
        end
        return i, v, remove
    end, t, ci
end

local cards_in_limbo={}
--op=2,Once per turn, if you control "Earthbound Immortal Wiraqocha Rasca",
-- you can target 1 monster your opponent controls; send it to the Underworld (It Dissapears from the Duel).
-- You cannot conduct your Battle Phase the turn you activate this effect.
function s.operation_for_res2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_MZONE, 1, 1, nil):GetFirst()
	if tc:IsType(TYPE_XYZ) then
		local mg=tc:GetOverlayGroup()
		Duel.SendtoGrave(mg,REASON_EFFECT)
	end
	table.insert(cards_in_limbo,tc)
	Duel.SendtoDeck(tc,1-tp,-2,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,6),nil)
	Duel.RegisterFlagEffect(tp,id+3,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

--op=3 set 1 "Contaminated Earth" from outside the duel to your Spell/Trap Zone.
function s.operation_for_res3(e,tp,eg,ep,ev,re,r,rp)
	local cearth=Duel.CreateToken(tp, 100000307)
	Duel.SSet(tp,cearth)
	Duel.RegisterFlagEffect(tp,id+4,0,0,0)
end

function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsCode(41181774) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
--
-- If a face-up "Earthbound Immortal Wiraqocha Rasca" you control leaves the field:
-- your opponent Special Summons as many of their monsters from the Underworld as possible,
-- ignoring their summoning conditions.

function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		local count=0
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		if ft2>0 then
		if Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT) then ft2=1 end
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local ng=Group.CreateGroup()

		for i, v, remove in ripairs(cards_in_limbo) do
			Group.AddCard(ng,v)
			remove()
		end
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local g=Group.Select(ng,1-tp,ft2,ft2,false,nil)
		if #g>0 then

			local tc=g:GetFirst()
			while tc do
				Duel.SpecialSummonStep(tc,0,1-tp,1-tp,true,true,POS_FACEUP)
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
				tc=g:GetNext()
				count=count+1
			end
		end
	end
	if count>0 then Duel.SpecialSummonComplete() end
end
