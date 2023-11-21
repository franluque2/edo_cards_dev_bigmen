--Takahashi's Legacy
--Skill Template
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

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PREDRAW)
		e2:SetCondition(s.changecon)
		e2:SetOperation(s.changeop)
		e2:SetCountLimit(1)
		Duel.RegisterEffect(e2,tp)

	end
	e:SetLabel(1)
end

local decks={{},{}}
for i = 0, 1 do
    decks[i] = {}

    for j = 0, 23 do
        decks[i][j] = {}
    end
end


-- monster, extra monster, backrow
decks[0][0] = { {32909498,32909498,32909498,32909498,32909498}, {84815190,84815190,84815190,84815190} , {55144522,55144522,55144522,55144522,55144522,55144522} }
decks[1][0] = { {32909498,32909498,32909498,32909498,32909498}, {84815190,84815190,84815190,84815190} , {55144522,55144522,55144522,55144522,55144522,55144522} }

decks[0][1] = { {32909498,32909498,32909498,32909498,32909498}, {84815190,84815190,84815190,84815190} , {55144522,55144522,55144522,55144522,55144522,55144522} }
decks[1][1] = { {32909498,32909498,32909498,32909498,32909498}, {84815190,84815190,84815190,84815190} , {55144522,55144522,55144522,55144522,55144522,55144522} }

decks[0][2] = { {32909498,32909498,32909498,32909498,32909498}, {84815190,84815190,84815190,84815190} , {55144522,55144522,55144522,55144522,55144522,55144522} }
decks[1][2] = { {32909498,32909498,32909498,32909498,32909498}, {84815190,84815190,84815190,84815190} , {55144522,55144522,55144522,55144522,55144522,55144522} }

decks[0][3] = { {32909498,32909498,32909498,32909498,32909498}, {84815190,84815190,84815190,84815190} , {55144522,55144522,55144522,55144522,55144522,55144522} }
decks[1][3] = { {32909498,32909498,32909498,32909498,32909498}, {84815190,84815190,84815190,84815190} , {55144522,55144522,55144522,55144522,55144522,55144522} }

decks[0][4] = { {}, {} , {} }
decks[1][4] = { {}, {} , {} }

decks[0][5] = { {}, {} , {} }
decks[1][5] = { {}, {} , {} }

decks[0][6] = { {}, {} , {} }
decks[1][6] = { {}, {} , {} }

decks[0][7] = { {}, {} , {} }
decks[1][7] = { {}, {} , {} }

decks[0][8] = { {}, {} , {} }
decks[1][8] = { {}, {} , {} }

decks[0][9] = { {}, {} , {} }
decks[1][9] = { {}, {} , {} }

decks[0][10] = { {}, {} , {} }
decks[1][10] = { {}, {} , {} }

decks[0][11] = { {}, {} , {} }
decks[1][11] = { {}, {} , {} }

decks[0][12] = { {}, {} , {} }
decks[1][12] = { {}, {} , {} }

decks[0][13] = { {}, {} , {} }
decks[1][13] = { {}, {} , {} }

decks[0][14] = { {}, {} , {} }
decks[1][14] = { {}, {} , {} }

decks[0][15] = { {}, {} , {} }
decks[1][15] = { {}, {} , {} }

decks[0][16] = { {}, {} , {} }
decks[1][16] = { {}, {} , {} }

decks[0][17] = { {}, {} , {} }
decks[1][17] = { {}, {} , {} }

decks[0][18] = { {}, {} , {} }
decks[1][18] = { {}, {} , {} }

decks[0][19] = { {}, {} , {} }
decks[1][19] = { {}, {} , {} }

decks[0][20] = { {}, {} , {} }
decks[1][20] = { {}, {} , {} }

decks[0][21] = { {}, {} , {} }
decks[1][21] = { {}, {} , {} }

decks[0][22] = { {}, {} , {} }
decks[1][22] = { {}, {} , {} }

decks[0][23] = { {}, {} , {} }
decks[1][23] = { {}, {} , {} }










function s.getyearval(tp)
	return math.ceil(Duel.GetTurnCount()/2) + Duel.GetFlagEffect(tp, id)
end


function s.changecon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()~=tp then return false end
    return Duel.GetTurnCount()>2 and (s.getyearval(tp)<=#decks[0])
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)


	s.updateyearval(tp)
	s.flipdownbackrow(tp)
	s.refillextra(tp)
	s.shufflebackpends(tp)
	s.changemononfield(tp)
	s.changebackrowonfield(tp)
	s.changeextra(tp)
	s.changeallelse(tp)


end

function s.updateyearval(tp)
	if Duel.IsExistingMatchingCard(s.nostalgiamonfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and s.getyearval(tp)<(#decks[0]-2) then
		Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	end
end

function s.flipdownbackrow(tp)
	local g=Duel.GetMatchingGroup(s.turnspelltrapfdfilter, tp, LOCATION_SZONE, 0, nil)

	if g and #g>0 then
		for tc in g:Iter() do
			if tc:IsType(TYPE_PENDULUM) then
				Duel.SendtoHand(tc, tp, REASON_RULE)
			else 
				Duel.ChangePosition(tc,POS_FACEDOWN)
			end
		end
	end
end

function s.refillextra(tp)
	local g=Duel.GetMatchingGroup(s.replaceextragravefilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, nil)

	if g and #g>0 then
		Duel.SendtoDeck(g, tp, SEQ_DECKTOP, REASON_RULE)
	end
end

function s.shufflebackpends(tp)
	local g=Duel.GetMatchingGroup(s.shufflependreplacefilter, tp, LOCATION_EXTRA, 0, nil)

	if g and #g>0 then
		Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_RULE)
	end
end

function s.changemononfield(tp)
	local g=Duel.GetMatchingGroup(s.replacemonfilter, tp, LOCATION_ONFIELD, 0, nil)

	if g and #g>0 then
		for tc in g:Iter() do
			if tc:IsAbleToExtraAsCost() then
				if #decks[tp][s.getyearval(tp)][2]==0 then return end
				local num=Duel.GetRandomNumber(1, #decks[tp][s.getyearval(tp)][2])
				Card.Recreate(tc, decks[tp][s.getyearval(tp)][2][num], nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
				table.remove(decks[tp][s.getyearval(tp)][2], num)
			else
				if #decks[tp][s.getyearval(tp)][1]==0 then return end
				local num=Duel.GetRandomNumber(1, #decks[tp][s.getyearval(tp)][1])
				Card.Recreate(tc, decks[tp][s.getyearval(tp)][1][num], nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
				table.remove(decks[tp][s.getyearval(tp)][1], num)
			end
		end
	end
end

function s.changebackrowonfield(tp)
	local g=Duel.GetMatchingGroup(s.replacespefilter, tp, LOCATION_ONFIELD, 0, nil)

	if g and #g>0 then
		for tc in g:Iter() do
			if #decks[tp][s.getyearval(tp)][3]==0 then return end
			local num=Duel.GetRandomNumber(1, #decks[tp][s.getyearval(tp)][3])
			Card.Recreate(tc, decks[tp][s.getyearval(tp)][3][num],nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
			table.remove(decks[tp][s.getyearval(tp)][3], num)
		end
	end
end

function s.changeextra(tp)
	local g=Duel.GetMatchingGroup(s.replacemonfilter, tp, LOCATION_EXTRA, 0, nil)


	if g and #g>0 then
		for tc in g:Iter() do
			if #decks[tp][s.getyearval(tp)][2]==0 then return end
			local num=Duel.GetRandomNumber(1, #decks[tp][s.getyearval(tp)][2])
			Card.Recreate(tc, decks[tp][s.getyearval(tp)][2][num],nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
			table.remove(decks[tp][s.getyearval(tp)][2], num)
		end
	end
	Duel.ShuffleExtra(tp)
end

function s.changeallelse(tp)
	local g=Duel.GetMatchingGroup(s.replacecardfilter, tp, LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_OVERLAY, 0, nil)

	if g and #g>0 then
		for tc in g:Iter() do
			local cardtyp=-1
			if #decks[tp][s.getyearval(tp)][1]==0 then
				if #decks[tp][s.getyearval(tp)][3]==0 then return end
				cardtyp=3
			end

			if #decks[tp][s.getyearval(tp)][3]==0 then
				cardtyp=1
			end

			if cardtyp==-1 then
				cardtyp=Duel.GetRandomNumber(1,2)
				if cardtyp==2 then cardtyp=3 end
			end

			local num=Duel.GetRandomNumber(1, #decks[tp][s.getyearval(tp)][cardtyp])
			Card.Recreate(tc, decks[tp][s.getyearval(tp)][cardtyp][num],nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
			table.remove(decks[tp][s.getyearval(tp)][cardtyp], num)
		end
	end
	Duel.ShuffleDeck(tp)
	Duel.ShuffleHand(tp)
end

local bosses={70781052,511002631,72989439,63519819,9596126,12538374,65192027,44508094,72896720,3429238,42752141,22110647,73964868,83531441,10443957,48905153,5043020,93854893,9464441,96633955,84330567,48626373}
local bossmonsters={}
bossmonsters[0]=Group.CreateGroup()
bossmonsters[1]=Group.CreateGroup()




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	if #bossmonsters[0]==0 then
		for i, v in pairs(bosses) do
			local token1=Duel.CreateToken(0, v)
			bossmonsters[0]:AddCard(token1)
			local token2=Duel.CreateToken(1, v)
			bossmonsters[1]:AddCard(token2)
		end
	end
end

function s.bondsunitydiscardfilter(c)
    return c:IsCode(15845914) and c:IsDiscardable(REASON_COST)
end

function s.thousandragondiscardfilter(c)
    return c:IsCode(0010000) and c:IsDiscardable(REASON_COST)
end

function s.nostalgiamonfilter(c)
    return c:IsCode(15845914,0010000) and c:IsFaceup()
end

function s.replacecardfilter(c)
	return (c:GetOwner()==c:GetControler() and not c:IsType(TYPE_TOKEN)) and not ((c:GetFlagEffect(id)>0) or c:IsCode(15845914,0010000))
end

function s.replacemonfilter(c)
    return (c:IsMonster() and c:GetOwner()==c:GetControler() and not c:IsType(TYPE_TOKEN)) and not ((c:GetFlagEffect(id)>0) or c:IsCode(15845914,0010000))
end

function s.replacespefilter(c)
    return c:IsSpellTrap() and c:GetOwner()==c:GetControler()
end

function s.replaceextragravefilter(c)
    return c:IsMonster() and c:IsAbleToExtraAsCost()
end

function s.shufflependreplacefilter(c)
    return c:IsMonster() and c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToDeck()
end

function s.turnspelltrapfdfilter(c)
	return s.replacespefilter(c) and c:IsFaceup()
end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end

	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.bondsunitydiscardfilter,tp,LOCATION_HAND,0,1,nil)
						and Duel.GetLocationCount(tp, LOCATION_MZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0
	and Duel.IsExistingMatchingCard(s.thousandragondiscardfilter,tp,LOCATION_HAND,0,1,nil)
				and Duel.GetLocationCount(tp, LOCATION_MZONE)>0


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0
	and Duel.IsExistingMatchingCard(s.bondsunitydiscardfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.GetLocationCount(tp, LOCATION_MZONE)>0

local b2=Duel.GetFlagEffect(tp,id+2)==0
	and Duel.IsExistingMatchingCard(s.thousandragondiscardfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.GetLocationCount(tp, LOCATION_MZONE)>0


--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
								  {b2,aux.Stringid(id,0)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s
	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end


function s.addxyzmaterial(tp, tc)
	--ariseheart
	if tc:IsCode(48626373) then
		local fenrir=Duel.CreateToken(tp, 32909498)
		Duel.SendtoGrave(fenrir, REASON_RULE)
		fenrir:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,fenrir)

		local bigbang=Duel.CreateToken(tp, 33925864)
		Duel.SendtoGrave(bigbang, REASON_RULE)
		bigbang:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,bigbang)
	end
	--dolkka
	if tc:IsCode(42752141) then
		local sabersaurus1=Duel.CreateToken(tp, 37265642)
		Duel.SendtoGrave(sabersaurus1, REASON_RULE)
		sabersaurus1:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,sabersaurus1)

		local sabersaurus2=Duel.CreateToken(tp, 37265642)
		Duel.SendtoGrave(sabersaurus2, REASON_RULE)
		sabersaurus2:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,sabersaurus2)
	end
	--dracossack
	if tc:IsCode(22110647) then
		local tempest=Duel.CreateToken(tp, 89399912)
		Duel.SendtoGrave(tempest, REASON_RULE)
		tempest:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,tempest)

		local tidal=Duel.CreateToken(tp, 26400609)
		Duel.SendtoGrave(tidal, REASON_RULE)
		tidal:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,tidal)
	end
	--pleiades
	if tc:IsCode(73964868) then
		local scythe=Duel.CreateToken(tp, 20292186)
		Duel.SendtoGrave(scythe, REASON_RULE)
		scythe:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,scythe)

		local moraltach=Duel.CreateToken(tp, 85103922)
		Duel.SendtoGrave(moraltach, REASON_RULE)
		bigbang:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,moraltach)
	end
	--dante
	if tc:IsCode(83531441) then
		local cir=Duel.CreateToken(tp, 57143342)
		Duel.SendtoGrave(cir, REASON_RULE)
		cir:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,cir)

		local farfa=Duel.CreateToken(tp, 36553319)
		Duel.SendtoGrave(farfa, REASON_RULE)
		farfa:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,farfa)
	end
	--cdi
	if tc:IsCode(10443957) then
		local tricklown=Duel.CreateToken(tp, 67696066)
		Duel.SendtoGrave(tricklown, REASON_RULE)
		tricklown:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,tricklown)

		local dmgjugg=Duel.CreateToken(tp, 68819554)
		Duel.SendtoGrave(dmgjugg, REASON_RULE)
		dmgjugg:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,dmgjugg)
	end
	--drident
	if tc:IsCode(48905153) then
		local whiptail=Duel.CreateToken(tp, 31755044)
		Duel.SendtoGrave(whiptail, REASON_RULE)
		whiptail:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,whiptail)

		local ramram=Duel.CreateToken(tp, 04145852)
		Duel.SendtoGrave(ramram, REASON_RULE)
		ramram:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,ramram)
	end
	--dingirsu
	if tc:IsCode(93854893) then
		local cymbal=Duel.CreateToken(tp, 21441617)
		Duel.SendtoGrave(cymbal, REASON_RULE)
		cymbal:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,cymbal)

		local wwand=Duel.CreateToken(tp, 93920420)
		Duel.SendtoGrave(wwand, REASON_RULE)
		wwand:RegisterFlagEffect(id, 0, 0, 0)
		Duel.Overlay(tc,wwand)
	end
end


function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
	local disc=Duel.SelectMatchingCard(tp, s.bondsunitydiscardfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
	if Duel.SendtoGrave(disc, REASON_DISCARD) then
		local year=s.getyearval(tp)
		if year > #bosses then year=#bosses	end
		local diff=#bosses-year

		local g=Group.CreateGroup()
		g:AddCard(bossmonsters[tp]:TakeatPos(year))
		if diff>0 then
			if diff==1 then
				g:AddCard(bossmonsters[tp]:TakeatPos(year+1))
				
			elseif diff==2 then
				g:AddCard(bossmonsters[tp]:TakeatPos(year+1))
				g:AddCard(bossmonsters[tp]:TakeatPos(year+2))
			else
				g:AddCard(bossmonsters[tp]:TakeatPos(year+1))
				g:AddCard(bossmonsters[tp]:TakeatPos(year+2))
				g:AddCard(bossmonsters[tp]:TakeatPos(year+3))

			end
		end
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tar=g:Select(tp, 1,1,false,nil)
		if tar then
			local token=Duel.CreateToken(tp, tar:GetFirst():GetOriginalCode())
			if token:IsType(TYPE_XYZ) then
				Duel.SpecialSummon(token, SUMMON_TYPE_XYZ, tp, tp, true, true, POS_FACEUP)
			elseif token:IsType(TYPE_SYNCHRO) then
				Duel.SpecialSummon(token, SUMMON_TYPE_SYNCHRO, tp, tp, true, true, POS_FACEUP)
			elseif token:IsType(TYPE_FUSION) then
				Duel.SpecialSummon(token, SUMMON_TYPE_FUSION, tp, tp, true, true, POS_FACEUP)
			elseif token:IsType(TYPE_LINK) then
				Duel.SpecialSummon(token, SUMMON_TYPE_LINK, tp, tp, true, true, POS_FACEUP)
			else
				Duel.SpecialSummon(token, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
			end

			if token:IsType(TYPE_XYZ) then
				s.addxyzmaterial(tp,token)
			end
			token:RegisterFlagEffect(id, 0, 0, 0)
		end
	end
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
	local disc=Duel.SelectMatchingCard(tp, s.thousandragondiscardfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
	if Duel.SendtoGrave(disc, REASON_DISCARD) then
		local year=s.getyearval(tp)-1
		local g=Group.CreateGroup()
		g:AddCard(bossmonsters[tp]:TakeatPos(year))
		if year>0 then
			if year==1 then
				g:AddCard(bossmonsters[tp]:TakeatPos(year-1))
				
			elseif year==2 then
				g:AddCard(bossmonsters[tp]:TakeatPos(year-1))
				g:AddCard(bossmonsters[tp]:TakeatPos(year-2))
			else
				g:AddCard(bossmonsters[tp]:TakeatPos(year-1))
				g:AddCard(bossmonsters[tp]:TakeatPos(year-2))
				g:AddCard(bossmonsters[tp]:TakeatPos(year-3))

			end
		end
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tar=g:Select(tp, 1,1,false,nil)
		if tar then
			local token=Duel.CreateToken(tp, tar:GetFirst():GetOriginalCode())
			Duel.SpecialSummon(token, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
			if token:IsType(TYPE_XYZ) then
				s.addxyzmaterial(tp,token)
			end
			token:RegisterFlagEffect(id, 0, 0, 0)

		end
	end
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
