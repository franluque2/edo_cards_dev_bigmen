--Gift of the Marked
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,1,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)
end


function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		e1:SetCountLimit(1)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id+1,0,0,0)

		local c=e:GetHandler()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCondition(s.adcon)
		e2:SetOperation(s.adop)
		Duel.RegisterEffect(e2,tp)


		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_SUMMON_SUCCESS)
		e8:SetOperation(s.tribute_catastrogue_check)
		Duel.RegisterEffect(e8,tp)

end
e:SetLabel(1)
	end

	function s.tribute_catastrogue_check(e,tp,eg,ev,ep,re,r,rp)
		local tc=eg:GetFirst()
		if tc:IsSummonType(SUMMON_TYPE_TRIBUTE) and tc:IsCode(100000143) then

			local mons=tc:GetMaterial()
			local ec=mons:GetFirst()
			while ec do
				ec:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,0)
				ec=mons:GetNext()
			end
		end
	end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	s.generatedtuners(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
local dtuners={}

local dtunerstoadd={100000140,100000141,100000142,100000143,100000144,100000145,100000146}

function s.generatedtuners(e,tp,eg,ep,ev,re,r,rp)
	for key,value in ipairs(dtunerstoadd) do
					newcard=Duel.CreateToken(tp, value)
					table.insert(dtuners,newcard)
	end
end

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


function s.catastrogueaddfilter(c)
	return c:IsCode(100000143) and c:IsAbleToHand()
end

function s.icemirrorshowfilter(c)
	return c:IsCode(69492187) and not c:IsPublic()
end

function s.blizzardfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER)
		and c:IsCode(100000157)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end


function s.monsterfilter(c)
	return c:IsFaceup() and c:HasLevel()
end

function s.catastroguetributefilter(c,e,tp)
	return c:IsType(TYPE_MONSTER)
		and (c:GetFlagEffect(id)>0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.dtunerfilter(c)
	return c:IsSetCard(0x600)
end


function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPT check
	if Duel.GetFlagEffect(tp,id+2)>0 and Duel.GetFlagEffect(tp, id+6)>0 and Duel.GetFlagEffect(tp, id+4)>0
	and Duel.GetFlagEffect(tp,id+5)>0 and Duel.GetFlagEffect(tp, id+7)>0 then return end
--
--  Once per turn, You can target 1 monster you control, and declare a level from 1-11,
-- until the end of this turn, that monster becomes that level, then you can make it become a dark tuner monster.
	local b1=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

--Once per turn, if you control 2 or more monsters, you can add 1 "Dark Tuner Catastrouge" from your Deck or GY to your Hand.
local b2=Duel.GetFlagEffect(tp, id+6)==0
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,2,nil)
		and Duel.IsExistingMatchingCard(s.catastrogueaddfilter,tp,LOCATION_DECK,0,1,nil)

--Once per turn, you can reveal 1 "Ice Mirror" in your Hand, Special Summon 1 "Blizzard Lizard" from Hand, Deck or GY.
		local b3=Duel.GetFlagEffect(tp, id+4)==0
			and Duel.IsExistingMatchingCard(s.icemirrorshowfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingMatchingCard(s.blizzardfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)

	--Once per turn, if you Tribute Summoned a "Dark Tuner Catastrouge" this turn,
	-- you can target 1 monster used for the Tribute Summon, Special Summon it in Defense Position.

	local b4=Duel.GetFlagEffect(tp, id+5)==0
		and Duel.IsExistingMatchingCard(s.catastroguetributefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)

--Once per turn, you can send 1 "Dark Tuner" monster from your Hand, Field or GY to the Underworld,
-- to Special Summon 1 "Dark Tuner" monster from outside the duel.

local b5=Duel.GetFlagEffect(tp, id+7)==0
	and Duel.IsExistingMatchingCard(s.dtunerfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
	and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)

	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4 or b5)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	--  Once per turn, You can target 1 monster you control, and declare a level from 1-11,
	-- until the end of this turn, that monster becomes that level, then you can make it become a dark tuner monster.
		local b1=Duel.GetFlagEffect(tp,id+2)==0
				and Duel.IsExistingMatchingCard(s.monsterfilter,tp,LOCATION_MZONE,0,1,nil)

	--Once per turn, if you control 2 or more monsters, you can add 1 "Dark Tuner Catastrouge" from your Deck or GY to your Hand.
	local b2=Duel.GetFlagEffect(tp, id+6)==0
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,2,nil)
			and Duel.IsExistingMatchingCard(s.catastrogueaddfilter,tp,LOCATION_DECK,0,1,nil)

	--Once per turn, you can reveal 1 "Ice Mirror" in your Hand, Special Summon 1 "Blizzard Lizard" from Hand, Deck or GY.
			local b3=Duel.GetFlagEffect(tp, id+4)==0
				and Duel.IsExistingMatchingCard(s.icemirrorshowfilter,tp,LOCATION_HAND,0,1,nil)
				and Duel.IsExistingMatchingCard(s.blizzardfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)

		--Once per turn, if you Tribute Summoned a "Dark Tuner Catastrouge" this turn,
		-- you can target 1 monster used for the Tribute Summon, Special Summon it in Defense Position.

		local b4=Duel.GetFlagEffect(tp, id+5)==0
			and Duel.IsExistingMatchingCard(s.catastroguetributefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)

	--Once per turn, you can send 1 "Dark Tuner" monster from your Hand, Field or GY to the Underworld,
	-- to Special Summon 1 "Dark Tuner" monster from outside the duel.

	local b5=Duel.GetFlagEffect(tp, id+7)==0
		and Duel.IsExistingMatchingCard(s.dtunerfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
		and (Duel.GetLocationCount(tp, LOCATION_MZONE)>0)

		local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									  {b2,aux.Stringid(id,2)},
									{b3,aux.Stringid(id,3)},
								{b4,aux.Stringid(id,4)},
							{b5,aux.Stringid(id,5)})
		op=op-1

	if op==0 then

		local tc=Duel.SelectMatchingCard(tp,s.monsterfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			if tc then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
				local lvl=Duel.AnnounceLevel(tp,1,11)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lvl)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					local e3=e1:Clone()
					e3:SetCode(EFFECT_ADD_TYPE)
					e3:SetValue(TYPE_TUNER)
					tc:RegisterEffect(e3)
					local e4=e1:Clone()
					e4:SetCode(EFFECT_ADD_SETCODE)
					e4:SetValue(0x600)
					tc:RegisterEffect(e4)
					local e5=Effect.CreateEffect(e:GetHandler())
					e5:SetType(EFFECT_TYPE_SINGLE)
					e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
					e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e5:SetValue(s.synlimit)
					e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e5)
				end
			end
			--opt register
			Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	elseif op==1 then

			local g=Duel.SelectMatchingCard(tp,s.catastrogueaddfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g, tp,REASON_EFFECT)
				Duel.ConfirmCards(1-tp, g)
			end
			Duel.RegisterFlagEffect(tp, id+6, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
	elseif op==2 then

		local g=Duel.SelectMatchingCard(tp,s.blizzardfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.RegisterFlagEffect(tp, id+4, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)

	elseif op==3 then
		local g=Duel.SelectMatchingCard(tp,s.catastroguetributefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		Duel.RegisterFlagEffect(tp, id+5, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
	elseif op==4 then
		local g=Duel.SelectMatchingCard(tp,s.dtunerfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoDeck(g, tp,-2,REASON_EFFECT)

			local ng=Group.CreateGroup()
			for i, v, remove in ripairs(dtuners) do
				Group.AddCard(ng,v)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=ng:Select(tp,1,1,nil)
			for i, v, remove in ripairs(dtuners) do
				if v:GetCode()==sg:GetFirst():GetCode() then
					remove()
				end
			end
		-- local newcard=Duel.CreateToken(tp, sg:GetFirst():GetCode())
		-- table.insert(dtuners,newcard)

		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)


		end
		Duel.RegisterFlagEffect(tp, id+7, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
	end
end



-- Once per turn, during each of your Standby Phases, add 1 random Dark Synchro monster, except "Moon Dragon Quilla" and "Hundred Eyes Dragon" to your Extra Deck.

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.GetTurnPlayer()==tp and not (Duel.GetFlagEffect(tp,id+3)>0) then return end



	return Duel.GetTurnPlayer()==tp
end

local table_dsynchro={100000151,100000152,100000154,100000155,100000156}
function s.getcard()
return table_dsynchro[ Duel.GetRandomNumber(1, #table_dsynchro ) ]
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)

		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,tp,id)

		local g=Duel.CreateToken(tp,s.getcard())
		Duel.SendtoDeck(g,tp,SEQ_DECKTOP,REASON_EFFECT)
	Duel.RegisterFlagEffect(tp, id+3, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
end


function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x601)
end
