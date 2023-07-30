--Duelist Energy MAX!!!
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
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

		--uncomment (remove the --) the line below to make it a rush skill
		--bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)


		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e6:SetCountLimit(1)
		e6:SetCondition(s.flipcon3)
		e6:SetOperation(s.flipop3)
		Duel.RegisterEffect(e6,tp)

		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		e5:SetCode(EVENT_TO_GRAVE)
		e5:SetCondition(s.descon)
		e5:SetOperation(s.desop)
		Duel.RegisterEffect(e5,tp)


		local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e3:SetDescription(aux.Stringid(81632652,0))
        e3:SetCode(id)
        e3:SetTargetRange(1,0)
        Duel.RegisterEffect(e3,tp)

		local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e4:SetDescription(aux.Stringid(81632652,0))
        e4:SetCode(id)
        e4:SetTargetRange(1,0)
        Duel.RegisterEffect(e4,1-tp)


        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_DAMAGE)
        e2:SetOperation(s.lpop)
        Duel.RegisterEffect(e2,tp)

		local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_ADD_CODE)
        e7:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
        e7:SetTarget(function(_,c)  return c:IsOriginalCode(78371393,511001391) end)
        e7:SetValue(06007213)
        Duel.RegisterEffect(e7,tp)

		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e0:SetTargetRange(LOCATION_ALL-LOCATION_OVERLAY,0)
		e0:SetTarget(function(_,c)  return c:IsOriginalCode(78371393,511001391) end)
		e0:SetValue(s.fuslimit)
		Duel.RegisterEffect(e0,tp)

	end
	e:SetLabel(1)
end

function s.fuslimit(e,c)
	if not c then return false end
	return c:IsSetCard(0x145)
end



function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(ep, 81632652)<10 then
		Duel.RegisterFlagEffect(ep, 81632652, 0, 0, 0)
			local ce=Duel.IsPlayerAffectedByEffect(ep,id)
			if ce then
				local nce=ce:Clone()
				ce:Reset()
				nce:SetDescription(aux.Stringid(81632652,Duel.GetFlagEffect(ep, 81632652)))
				Duel.RegisterEffect(nce,ep)
			end
       
    end
end


function s.destroyedortributedfilter(c)
	return (c:IsReason(REASON_DESTROY) or c:IsReason(REASON_RELEASE)) and c:GetFlagEffect(id)>0
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.destroyedortributedfilter,1,nil)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

	local tc=eg:GetFirst()
	while tc do
		if tc:GetFlagEffect(id)==1 then
			Duel.Recover(tp, 500, REASON_RULE)
		elseif tc:GetFlagEffect(id)==2 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.Recover(tp, 800, REASON_RULE)
		elseif tc:GetFlagEffect(id)==3 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.Recover(tp, 1000, REASON_RULE)
		end
	tc=eg:GetNext()
	end
end

function s.flipcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(s.sfgfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end
function s.flipop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	
	local g=Duel.CreateToken(tp,s.getrandomfusion())
	Fusion.AddProcMixN(g,true,true,s.fusop,2)
	Duel.SendtoDeck(g,tp,SEQ_DECKTOP,REASON_EFFECT)


end

local tablefusions={62873545, 99267150, 23995346, 13331639, 54702678, 37440988, 8505920, 81632418, 32615065, 43378048, 22723778, 51788412, 72664875, 86346643, 12652643, 4628897, 65172015, 95463814, 1546123, 24550676, 84569886, 45014450, 51570882, 59255742, 41685633, 14017402, 42166000, 76263644, 93657021, 2129638, 96220350, 99991455, 29343734, 69394324, 40101111, 58468105, 17745969, 27134689, 3897065, 6150044, 11901678, 45349196, 511018034, 87804747, 10817524, 86676862, 90660762, 100000570, 21225115, 22900219, 86165817, 37818794, 84243274, 41721210, 92892239, 36256625, 8198620, 511009382, 98502113, 49820233, 511002039, 91998119, 20366274, 97165977, 4591250, 90579153, 25793414, 6602300, 50237654, 45170821, 74157028, 37261776, 41209827, 83866861, 96897184, 511001057, 49161188, 87751584, 9910360, 46759931, 74711057, 80889750, 40636712, 3779662, 87182127, 40418351, 511600250, 100000022, 54752875, 21175632, 2504891, 66889139, 37057012, 71628381, 68507541, 11502550, 25586143, 42717221, 93729065, 99551425, 72926163, 511009336, 51777272, 81632103, 511009105, 13756293, 25655502, 62111090, 5600127, 91272072, 10248389, 511009335, 24672164, 7243511, 32775808, 57594700, 61204971, 48156348, 29455728, 511009391, 511009390, 10365322, 85545073, 33129626, 5368615, 511002704, 86805855, 4796100, 53539634, 35809262, 81632414, 511000117, 86239173, 52031567, 49868263, 1412158, 75923050, 84988419, 13803864, 90140980, 511005604, 26273196, 80071763, 66235877, 51828629, 45231177, 56907389, 3366982, 16114248, 6840573, 85684223, 40391316, 72959823, 80532587, 17412721, 54757758, 17881964, 54541900, 76815942, 41578483, 63519819}

function s.getrandomfusion()
	return tablefusions[ Duel.GetRandomNumber(1, #tablefusions ) ]
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.fusionfilter(c)
	return c:IsType(TYPE_FUSION) and not (c:IsCode(81632387) or c:IsSetCard(0x145))
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_EXTRA,0,nil)

	local tc=g:GetFirst()
	while tc do
		Fusion.AddProcMixN(tc,true,true,s.fusop,2)
		tc=g:GetNext()
	end
	
end

function s.sfgfilter(c)
	--
    return c:IsCode(81632387) and c:IsFaceup()
end

function s.fusop(_,c)
	return Duel.IsExistingMatchingCard(s.sfgfilter, c:GetOwner(), LOCATION_ONFIELD, 0, 1,nil)
end

function s.putbackyubelfilter(c)
	return c:IsCode(78371393, 31764700, 04779091) and c:IsAbleToDeck() and not c:IsPublic()
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp, id+8)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0 and (
			(Duel.GetFlagEffect(tp,id+2)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>2 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
			or (Duel.GetFlagEffect(tp,id+3)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>4 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
			or (Duel.GetFlagEffect(tp,id+9)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>7 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
			or (Duel.GetFlagEffect(tp,id+4)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>9 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
			or (Duel.GetFlagEffect(tp,id+5)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>11)
			or (Duel.GetFlagEffect(tp,id+10)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>1 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>11)
			or (Duel.GetFlagEffect(tp,id+6)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>14)
			or (Duel.GetFlagEffect(tp,id+7)==0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>1 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>19))

	local b2=Duel.GetFlagEffect(tp,id+8)==0 and Duel.IsExistingMatchingCard(s.putbackyubelfilter, tp, LOCATION_HAND, 0, 1, nil) and Duel.IsPlayerCanDraw(tp)

--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0 and (
	(Duel.GetFlagEffect(tp,id+2)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>2 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
	or (Duel.GetFlagEffect(tp,id+3)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>4 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
	or (Duel.GetFlagEffect(tp,id+9)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>7 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
	or (Duel.GetFlagEffect(tp,id+4)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>9 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
	or (Duel.GetFlagEffect(tp,id+5)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>11)
	or (Duel.GetFlagEffect(tp,id+10)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>1 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>11)
	or (Duel.GetFlagEffect(tp,id+6)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>14)
	or (Duel.GetFlagEffect(tp,id+7)==0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>1 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>19))

local b2=Duel.GetFlagEffect(tp,id+8)==0 and Duel.IsExistingMatchingCard(s.putbackyubelfilter, tp, LOCATION_HAND, 0, 1, nil) and Duel.IsPlayerCanDraw(tp)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									{b2,aux.Stringid(id,8)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end


function s.summonandtag(tokenid,tp,flagnum)
	local token=Duel.CreateToken(tp, tokenid)
	Duel.SpecialSummon(token, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)

	for var=0,flagnum-1 do
		token:RegisterFlagEffect(id, RESETS_STANDARD, 0, 0)
	 end
	
end

function s.removecounters(num,tp)
	local n1=Duel.GetFlagEffect(tp, 81632652)
	local n2=Duel.GetFlagEffect(1-tp, 81632652)

	if n1+n2==num then
		Duel.ResetFlagEffect(tp, 81632652)
		Duel.ResetFlagEffect(1-tp, 81632652)
	elseif n1==0 then
		local rest = n2-num

		Duel.ResetFlagEffect(1-tp, 81632652)
		for var=1,rest do
			Duel.RegisterFlagEffect(1-tp, 81632652, 0, 0, 0)
		end
	elseif n2==0 then

		local rest = n1-num
		Duel.ResetFlagEffect(tp, 81632652)
		for var=1,rest do
			Duel.RegisterFlagEffect(tp, 81632652, 0, 0, 0)
		end

	else
		Duel.Hint(HINT_MESSAGE, tp, aux.Stringid(id, 7))

		local rest = num-n2
		if rest<0 then rest=0 end
		local validnumbers={}

		for var=rest,n1 do
			table.insert(validnumbers,var)
		end
		
		local n=Duel.AnnounceNumber(tp, table.unpack(validnumbers))

		Duel.ResetFlagEffect(tp, 81632652)
		Duel.ResetFlagEffect(1-tp, 81632652)

		for var=1,n1-n do
			Duel.RegisterFlagEffect(tp, 81632652, 0, 0, 0)
		end

		for var=1,n2-(num-n) do
			Duel.RegisterFlagEffect(1-tp, 81632652, 0, 0, 0)
		end
	end

    local ce=Duel.IsPlayerAffectedByEffect(tp,id)
    if ce then
		local nce=ce:Clone()
		ce:Reset()
		nce:SetDescription(aux.Stringid(81632652,Duel.GetFlagEffect(tp, 81632652)))
		Duel.RegisterEffect(nce,tp)
    end

	ce=Duel.IsPlayerAffectedByEffect(1-tp,id)
    if ce then
		local nce=ce:Clone()
		ce:Reset()
		nce:SetDescription(aux.Stringid(81632652,Duel.GetFlagEffect(1-tp, 81632652)))
		Duel.RegisterEffect(nce,1-tp)
    end
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local b1=(Duel.GetFlagEffect(tp,id+2)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>2 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
	local b2=(Duel.GetFlagEffect(tp,id+3)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>4 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
	local b3=(Duel.GetFlagEffect(tp,id+9)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>7 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
	local b4=(Duel.GetFlagEffect(tp,id+4)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>9 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT))
	local b5=(Duel.GetFlagEffect(tp,id+5)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>11)
	local b6=(Duel.GetFlagEffect(tp,id+10)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>1 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>11)
	local b7=(Duel.GetFlagEffect(tp,id+6)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>14)
	local b8=(Duel.GetFlagEffect(tp,id+7)==0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>1 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>19)


	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
									{b2,aux.Stringid(id,2)},
									{b3,aux.Stringid(id,10)},
									{b4,aux.Stringid(id,3)},
									{b5,aux.Stringid(id,4)},
									{b6,aux.Stringid(id,9)},
									{b7,aux.Stringid(id,5)},
									{b8,aux.Stringid(id,6)})
	op=op-1

	if op==0 then
		s.removecounters(3,tp)

		s.summonandtag(12482652,tp,1)
		s.summonandtag(42941100,tp,1)
		s.summonandtag(79335209,tp,1)

		Duel.RegisterFlagEffect(tp,id+2,0,0,0)
	elseif op==1 then
		s.removecounters(5,tp)

		s.summonandtag(71218746,tp,1)
		s.summonandtag(61538782,tp,1)
		
		Duel.RegisterFlagEffect(tp,id+3,0,0,0)
	elseif op==2 then
		s.removecounters(8,tp)

		s.summonandtag(67316075,tp,1)
		s.summonandtag(41859700,tp,1)
		s.summonandtag(41859700,tp,1)

		Duel.RegisterFlagEffect(tp,id+9,0,0,0)
	elseif op==3 then
		s.removecounters(10,tp)

		s.summonandtag(10509340,tp,1)
		s.summonandtag(01953925,tp,1)
		s.summonandtag(56094445,tp,1)

		Duel.RegisterFlagEffect(tp,id+4,0,0,0)
	elseif op==4 then
		s.removecounters(12,tp)

		local ft=Duel.GetLocationCount(tp, LOCATION_MZONE)
		if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft=1 end
		for i = 1,ft,1 do 
			s.summonandtag(22499463,tp,1)
		end

		Duel.RegisterFlagEffect(tp,id+5,0,0,0)
	elseif op==5 then
		s.removecounters(12,tp)

		s.summonandtag(81632229,tp,1)

		local toycannon=Duel.CreateToken(tp, 81632240)
		Duel.SSet(tp, toycannon)

		Duel.RegisterFlagEffect(tp,id+10,0,0,0)
	elseif op==6 then
		s.removecounters(15,tp)

		local token=Duel.CreateToken(tp, 78371393)
		Duel.SpecialSummon(token, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
		token:RegisterFlagEffect(id, RESETS_STANDARD, 0, 0)

		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e2:SetValue(s.atlimit)
		token:RegisterEffect(e2)
	
		Duel.RegisterFlagEffect(tp,id+6,0,0,0)
	elseif op==7 then
		s.removecounters(20,tp)

		
		local mat_lvl1=Duel.CreateToken(tp,48343627)
		local mat_lvl2=Duel.CreateToken(tp,95178994)
		local mat_lvl3=Duel.CreateToken(tp,54040484)
		local mat_lvl4=Duel.CreateToken(tp,30312361)
		local mat_lvl5=Duel.CreateToken(tp,87917187)
		local mat_lvl6=Duel.CreateToken(tp,23309606)
		local mat_lvl7=Duel.CreateToken(tp,8794435)
		local mat_lvl8=Duel.CreateToken(tp,102380)
		local mat_lvl9=Duel.CreateToken(tp,19847532)
		local mat_lvl10=Duel.CreateToken(tp,69890967)
		local mat_lvl11=Duel.CreateToken(tp,25833572)
		local mat_lvl12=Duel.CreateToken(tp,31764700)



		g=Group.CreateGroup()
		g:AddCard(mat_lvl1)
		g:AddCard(mat_lvl2)
		g:AddCard(mat_lvl3)
		g:AddCard(mat_lvl4)
		g:AddCard(mat_lvl5)
		g:AddCard(mat_lvl6)
		g:AddCard(mat_lvl7)
		g:AddCard(mat_lvl8)
		g:AddCard(mat_lvl9)
		g:AddCard(mat_lvl10)
		g:AddCard(mat_lvl11)
		g:AddCard(mat_lvl12)
		Duel.SendtoDeck(g,tp,SEQ_DECKBOTTOM,REASON_RULE)

		local spoly=Duel.CreateToken(tp, 48130397)
		Duel.SendtoHand(spoly, tp, REASON_RULE)

		local chainmat=Duel.CreateToken(tp, 39980304)
		Duel.SSet(tp, chainmat)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		chainmat:RegisterEffect(e2)

		Duel.RegisterFlagEffect(tp,id+7,0,0,0)
	end



--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end

function s.atlimit(e,c)
	return c:IsFaceup() and c:GetCode()~=78371393
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)

Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
local yubel=Duel.SelectMatchingCard(tp, s.putbackyubelfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
if yubel then
	Duel.ConfirmCards(1-tp, yubel)
	Duel.SendtoDeck(yubel, tp, SEQ_DECKBOTTOM, REASON_RULE)
	Duel.Draw(tp, 1, REASON_RULE)
end


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
