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

		local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD)
		e8:SetCode(EFFECT_CHANGE_DAMAGE)
		e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e8:SetTargetRange(0,1)
		e8:SetValue(s.damval)
		Duel.RegisterEffect(e8,tp)

		local e7=Effect.CreateEffect(e:GetHandler())
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e7:SetTargetRange(LOCATION_MZONE,0)
		e7:SetTarget(s.rdtg)
		e7:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
		Duel.RegisterEffect(e7,tp)

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

	end
	e:SetLabel(1)
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
	
	local g=Duel.CreateToken(tp,s.getcard())
	Fusion.AddProcMixN(g,true,true,s.fusop,2)
	Duel.SendtoDeck(g,tp,SEQ_DECKTOP,REASON_EFFECT)


end

local tablefusions={60461804,37818794,84330567,44146295,55990317}

function s.getrandomfusion()
	return tablefusions[ Duel.GetRandomNumber(1, #tablefusions ) ]
end


function s.damval(e,re,val,r,rp)
	if re then
		local rc=re:GetHandler()
		if rc:IsFaceup() and (rc:ListsCode(78371393) or rc:IsCode(31764700,04779091,05126490,90307498)) then
			return math.floor(val/2)
		end
	end
	return val
end


function s.rdtg(e,c)
	return c:ListsCode(78371393) or c:IsCode(31764700,04779091,05126490,90307498)
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
	return c:IsType(TYPE_FUSION)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	local yubel=Duel.CreateToken(tp, 78371393)
	Duel.SpecialSummon(yubel, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)

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

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0 and (
			(Duel.GetFlagEffect(tp,id+2)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>2)
			or (Duel.GetFlagEffect(tp,id+3)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>4
			or (Duel.GetFlagEffect(tp,id+4)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>9
			or (Duel.GetFlagEffect(tp,id+5)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>3) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>11
			or (Duel.GetFlagEffect(tp,id+6)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>14
			or (Duel.GetFlagEffect(tp,id+7)==0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>1) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>19)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

local b1=Duel.GetFlagEffect(tp,id+1)==0 and (
	(Duel.GetFlagEffect(tp,id+2)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2 and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>2)
	or (Duel.GetFlagEffect(tp,id+3)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>4
	or (Duel.GetFlagEffect(tp,id+4)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>9
	or (Duel.GetFlagEffect(tp,id+5)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>3) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>11
	or (Duel.GetFlagEffect(tp,id+6)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>14
	or (Duel.GetFlagEffect(tp,id+7)==0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>1) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>19)

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	--elseif op==1 then
		--s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
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
	local b1= (Duel.GetFlagEffect(tp,id+2)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>2
	local b2= (Duel.GetFlagEffect(tp,id+3)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>1) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>4
	local b3= (Duel.GetFlagEffect(tp,id+4)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>9
	local b4= (Duel.GetFlagEffect(tp,id+5)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>3) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>11
	local b5= (Duel.GetFlagEffect(tp,id+6)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>2) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>14
	local b6= (Duel.GetFlagEffect(tp,id+7)==0 and Duel.GetLocationCount(tp, LOCATION_SZONE)>1) and (Duel.GetFlagEffect(tp, 81632652)+Duel.GetFlagEffect(1-tp, 81632652))>19

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
									{b2,aux.Stringid(id,2)},
									{b3,aux.Stringid(id,3)},
									{b4,aux.Stringid(id,4)},
									{b5,aux.Stringid(id,5)},
									{b6,aux.Stringid(id,6)})
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
		s.removecounters(10,tp)

		s.summonandtag(10509340,tp,1)
		s.summonandtag(01953925,tp,1)
		s.summonandtag(56094445,tp,1)

		Duel.RegisterFlagEffect(tp,id+4,0,0,0)
	elseif op==3 then
		s.removecounters(12,tp)

		s.summonandtag(22499463,tp,2)
		s.summonandtag(22499463,tp,2)
		s.summonandtag(22499463,tp,2)
		s.summonandtag(22499463,tp,2)

		Duel.RegisterFlagEffect(tp,id+5,0,0,0)
	elseif op==4 then
		s.removecounters(15,tp)

		s.summonandtag(6007213,tp,3)
		s.summonandtag(32491822,tp,3)
		s.summonandtag(69890967,tp,3)

		Duel.RegisterFlagEffect(tp,id+6,0,0,0)
	elseif op==5 then
		s.removecounters(20,tp)

		
		local mat_lvl1=Duel.CreateToken(tp,80825553)
		local mat_lvl2=Duel.CreateToken(tp,76145933)
		local mat_lvl3=Duel.CreateToken(tp,10802915)
		local mat_lvl4=Duel.CreateToken(tp,86120751)
		local mat_lvl5=Duel.CreateToken(tp,20932152)
		local mat_lvl6=Duel.CreateToken(tp,17330916)
		local mat_lvl7=Duel.CreateToken(tp,32909498)
		local mat_lvl8=Duel.CreateToken(tp,55063751)
		local mat_lvl9=Duel.CreateToken(tp,68199168)
		local mat_lvl10=Duel.CreateToken(tp,27279764)
		local mat_lvl11=Duel.CreateToken(tp,27204311)
		local mat_lvl12=Duel.CreateToken(tp,80630522)



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
