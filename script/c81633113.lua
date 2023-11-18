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

local decks={}
decks[0] = { {}, {} , {} }
decks[1] = { {}, {} , {} }
decks[2] = { {}, {} , {} }
decks[3] = { {}, {} , {} }
decks[4] = { {}, {} , {} }
decks[5] = { {}, {} , {} }
decks[6] = { {}, {} , {} }
decks[7] = { {}, {} , {} }
decks[8] = { {}, {} , {} }
decks[9] = { {}, {} , {} }
decks[10] = { {}, {} , {} }
decks[11] = { {}, {} , {} }
decks[12] = { {}, {} , {} }
decks[13] = { {}, {} , {} }
decks[14] = { {}, {} , {} }
decks[15] = { {}, {} , {} }
decks[16] = { {}, {} , {} }
decks[17] = { {}, {} , {} }
decks[18] = { {}, {} , {} }
decks[19] = { {}, {} , {} }
decks[20] = { {}, {} , {} }
decks[21] = { {}, {} , {} }
decks[22] = { {}, {} , {} }
decks[23] = { {}, {} , {} }

function s.getyearval(tp)
	return math.ceil(Duel.GetTurnCount()/2) + Duel.GetFlagEffect(tp, id)
end


function s.changecon(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.GetTurnPlayer()==tp then return false end
    return Duel.GetTurnCount()>2 and (s.getyearval(tp)<=#decks)
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)



end

function s.flipdownbackrow(tp)

end

function s.refillextra(tp)
end

function s.shufflebackpends(tp)
end

local bosses={48626373,48626373,48626373,48626373,48626373,48626373}
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
			Duel.SpecialSummon(token, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)

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
		local year=s.getyearval(tp)
		local g=Group.CreateGroup()
		g:AddCard(bossmonsters[tp]:TakeatPos(year))
		if year>1 then
			if year==2 then
				g:AddCard(bossmonsters[tp]:TakeatPos(year-1))
				
			elseif year==3 then
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
