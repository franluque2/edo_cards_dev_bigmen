
--Phantom Four
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
        gPend.AddYuyaProcedure()(e,tp,eg,ep,ev,re,r,rp)

		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_BECOME_LINKED_ZONE)
		e6:SetRange(LOCATION_FZONE)
		e6:SetValue(s.value)
		Duel.RegisterEffect(e6,tp)

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_FORCE_MZONE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetTargetRange(1,0)
		e3:SetValue(s.znval)
		Duel.RegisterEffect(e3,tp)

		local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_ADJUST)
		e9:SetCondition(s.removeloccon)
		e9:SetOperation(s.removelocop)
        Duel.RegisterEffect(e9,tp)

		--pk traps can be treated as level 7

		local e10=Effect.CreateEffect(e:GetHandler())
		e10:SetType(EFFECT_TYPE_FIELD)
		e10:SetCode(EFFECT_XYZ_LEVEL)
		e10:SetTargetRange(LOCATION_MZONE, 0)
		e10:SetTarget(function (_,c) return gPend.PkTrapFilter(c)~=nil end)
		e10:SetValue(s.xyzlv)
        Duel.RegisterEffect(e10,tp)

	end
	e:SetLabel(1)
end

function s.xyzlv(e,c,rc)
	return 0x70000+rc:GetLevel()
end

function s.removeloccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON)
end
function s.removelocop(e,tp,eg,ep,ev,re,r,rp)
	while Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON) do
		Duel.IsPlayerAffectedByEffect(tp, EFFECT_CANNOT_SPECIAL_SUMMON):Reset()
	end
end


function s.value(e)
	return 0x1f<<16*e:GetHandlerPlayer()
end

function s.znval(e)
	return ~(0x60)
end







function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	--start of duel effects go here

	s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.startofdueleff(e,tp,eg,ep,ev,re,r,rp)


end


--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return false
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	--if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	--local b1=Duel.GetFlagEffect(tp,id+1)==0
			--and Duel.IsExistingMatchingCard(s.icustomfilter,tp,LOCATION_ONFIELD,0,1,nil)
						--and Duel.IsExistingMatchingCard(s.conttrapfiler,tp,LOCATION_DECK,0,1,nil)

	--local b2=Duel.GetFlagEffect(tp,id+2)==0
			--and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp)


--return the b1 or b2 or .... in parenthesis at the end
	--return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
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






graveyardpend={}

gPend=graveyardpend

function gPend.AddYuyaProcedure()
  return function(e,tp,eg,ep,ev,re,r,rp)

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1074)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(gPend.Condition)
	e1:SetOperation(gPend.Operation)
	e1:SetValue(SUMMON_TYPE_PENDULUM)

	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(s.checkop)
	Duel.RegisterEffect(e2,tp)


    Duel.RegisterFlagEffect(e:GetHandlerPlayer(), 10000000, 0, 0, 0)

    end
end

function s.checkop(e,tp)
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz~=nil and lpz:GetFlagEffect(id)<=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetDescription(1074)
		e1:SetCode(EFFECT_SPSUMMON_PROC_G)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_PZONE)
		e1:SetCondition(gPend.Condition)
		e1:SetOperation(gPend.Operation)
		e1:SetValue(SUMMON_TYPE_PENDULUM)
		lpz:RegisterEffect(e1)
		lpz:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
	local olpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
	local orpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
	if olpz~=nil and orpz~=nil and olpz:GetFlagEffect(id)<=0
		and olpz:GetFlagEffectLabel(31531170)==orpz:GetFieldID()
		and orpz:GetFlagEffectLabel(31531170)==olpz:GetFieldID() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetDescription(1074)
			e1:SetCode(EFFECT_SPSUMMON_PROC_G)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetRange(LOCATION_PZONE)
			e1:SetCondition(gPend.Condition)
			e1:SetOperation(gPend.Operation)
			e1:SetValue(SUMMON_TYPE_PENDULUM)
			olpz:RegisterEffect(e2)
		olpz:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end

gPend.PkTraps={}
gPend.PkTraps[98827725]=4
gPend.PkTraps[09336190]=4
gPend.PkTraps[24212820]=4
gPend.PkTraps[36247316]=2
gPend.PkTraps[51606429]=3
gPend.PkTraps[62645025]=2
gPend.PkTraps[77462146]=4

function gPend.PkTrapFilter(c)
    if not c:IsCode(98827725,09336190,24212820,36247316,
    51606429,62645025,77462146) then return nil end
    return gPend.PkTraps[c:GetCode()]
end

function gPend.IsValidPkTrapSummon(c,lscale,rscale)
    if gPend.PkTrapFilter(c)==nil then return false end

    tp=c:GetControler()

    if c:GetCode()==98827725 then
        return Duel.IsPlayerCanSpecialSummonMonster(tp,98827725,SET_THE_PHANTOM_KNIGHTS,TYPE_MONSTER+TYPE_NORMAL,0,300,4,RACE_WARRIOR,ATTRIBUTE_DARK)
            and lscale<4 and rscale>4
    end

    if c:GetCode()==09336190 then
        return Duel.IsPlayerCanSpecialSummonMonster(tp,98827725,SET_THE_PHANTOM_KNIGHTS,TYPE_MONSTER+TYPE_NORMAL,0,300,4,RACE_WARRIOR,ATTRIBUTE_DARK)
            and lscale<4 and rscale>4
    end

    if c:GetCode()==24212820 then
        return Duel.IsPlayerCanSpecialSummonMonster(tp,98827725,SET_THE_PHANTOM_KNIGHTS,TYPE_MONSTER+TYPE_NORMAL,0,300,4,RACE_WARRIOR,ATTRIBUTE_DARK)
            and lscale<4 and rscale>4
    end

    if c:GetCode()==36247316 then
        return Duel.IsPlayerCanSpecialSummonMonster(tp,36247316,SET_THE_PHANTOM_KNIGHTS,TYPE_MONSTER+TYPE_NORMAL,0,300,2,RACE_WARRIOR,ATTRIBUTE_DARK)
            and lscale<2 and rscale>2
    end

    if c:GetCode()==51606429 then
        return Duel.IsPlayerCanSpecialSummonMonster(tp,51606429,SET_THE_PHANTOM_KNIGHTS,TYPE_MONSTER+TYPE_NORMAL,0,300,3,RACE_WARRIOR,ATTRIBUTE_DARK)
            and lscale<3 and rscale>3
    end

    if c:GetCode()==62645025 then
        return Duel.IsPlayerCanSpecialSummonMonster(tp,62645025,SET_THE_PHANTOM_KNIGHTS,TYPE_MONSTER+TYPE_NORMAL,0,300,2,RACE_WARRIOR,ATTRIBUTE_DARK)
            and lscale<2 and rscale>2
    end

    if c:GetCode()==77462146 then
        return Duel.IsPlayerCanSpecialSummonMonster(tp,77462146,SET_THE_PHANTOM_KNIGHTS,TYPE_MONSTER+TYPE_NORMAL,0,300,4,RACE_WARRIOR,ATTRIBUTE_DARK)
            and lscale<4 and rscale>4
    end
end

function gPend.PreparePkTrap(c)
        tp=c:GetControler()
    
        if c:GetCode()==98827725 then
			
            c:AddMonsterAttribute(TYPE_NORMAL)
			Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
            c:AddMonsterAttributeComplete()
            return
        end
    
        if c:GetCode()==09336190 then
            c:AddMonsterAttribute(TYPE_NORMAL,0,0,4,0,0)
			Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
            c:AssumeProperty(ASSUME_RACE,RACE_WARRIOR)
            c:AddMonsterAttributeComplete()

            local e1=Effect.CreateEffect(c)
			e1:SetDescription(3300)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			c:RegisterEffect(e1,true)

            return
        end
    
        if c:GetCode()==24212820 then
            c:AddMonsterAttribute(TYPE_EFFECT)
			Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
			c:AssumeProperty(ASSUME_RACE,RACE_WARRIOR)
            c:AddMonsterAttributeComplete()
            --Banish it if it leaves the field
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3300)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1,true)
    
            
            return
        end
    
        if c:GetCode()==36247316 then
            c:AddMonsterAttribute(TYPE_NORMAL)
			Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
			c:AddMonsterAttributeComplete()
            return
        end
    
        if c:GetCode()==51606429 then
            c:AddMonsterAttribute(TYPE_NORMAL)
			Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
            c:AddMonsterAttributeComplete()
            return
        end
    
        if c:GetCode()==62645025 then
            c:AddMonsterAttribute(TYPE_EFFECT)
			Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
            c:AddMonsterAttributeComplete()
            return
        end
    
        if c:GetCode()==77462146 then
            c:AddMonsterAttribute(TYPE_NORMAL)
			Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
            c:AssumeProperty(ASSUME_RACE,RACE_WARRIOR)
            c:AddMonsterAttributeComplete()
            --Banish it if it leaves the field
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3300)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1,true)

            return
        end
end

function gPend.Filter(c,e,tp,lscale,rscale,lvchk)
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
    else if not gPend.PkTrapFilter(c)==nil then
        lv=gPend.PkTraps[c:GetCode()]
	else end
		lv=c:GetLevel()
	end
	return (c:IsLocation(LOCATION_HAND) or ((c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA))
        or (c:IsLocation(LOCATION_GRAVE) and c:IsSummonableCard() )))
		and ((lvchk or (lv>lscale and lv<rscale) or c:IsHasEffect(511004423)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false) or gPend.IsValidPkTrapSummon(c,lscale,rscale))
		and not c:IsForbidden()
end
function gPend.Condition(e,c,ischain,re,rp)
				if c==nil then return true end

				local tp=c:GetControler()
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				if rpz==nil or c==rpz or (not inchain and Duel.GetFlagEffect(tp,81632992-500)>0) then return false end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				local loc=0
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
				if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
                if Duel.GetLocationCountFromEx(tp, tp, nil, TYPE_PENDULUM, 0x1f)>0 then loc=loc+LOCATION_GRAVE end
				if loc==0 then return false end
				local g=nil
				if og then
					g=og:Filter(Card.IsLocation,nil,loc)
				else
					g=Duel.GetFieldGroup(tp,loc,0)
				end
				return g:IsExists(gPend.Filter,1,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
			end
function gPend.Operation(e,tp,eg,ep,ev,re,r,rp,c,sg,inchain)
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
				local ft=Duel.GetUsableMZoneCount(tp)
				if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
					if ft1>0 then ft1=1 end
					if ft2>0 then ft2=1 end
					ft=1
				end
				local loc=0
				if ft1>0 then loc=loc+LOCATION_HAND+LOCATION_GRAVE end
				if ft2>0 then loc=loc+LOCATION_EXTRA end
				local tg=nil
				if og then
					tg=og:Filter(Card.IsLocation,nil,loc):Match(gPend.Filter,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
				else
					tg=Duel.GetMatchingGroup(gPend.Filter,tp,loc,0,nil,e,tp,lscale,rscale,c:IsHasEffect(511007000) and rpz:IsHasEffect(511007000))
				end
				ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_GRAVE))
				ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
				ft2=math.min(ft2,aux.CheckSummonGate(tp) or ft2)
				while true do
					local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_GRAVE)
					local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
					local ct=ft
					if ct1>ft1 then ct=math.min(ct,ft1) end
					if ct2>ft2 then ct=math.min(ct,ft2) end
					local loc=0
					if ft1>0 then loc=loc+LOCATION_HAND+LOCATION_GRAVE end
					if ft2>0 then loc=loc+LOCATION_EXTRA end
					local g=tg:Filter(Card.IsLocation,sg,loc)
					if #g==0 or ft==0 then break end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local tc=Group.SelectUnselect(g,sg,tp,#sg>0,Duel.IsSummonCancelable())
					if not tc then break end
					if sg:IsContains(tc) then
						sg:RemoveCard(tc)
						if tc:IsLocation(LOCATION_HAND+LOCATION_GRAVE) then
							ft1=ft1+1
						else
							ft2=ft2+1
						end
						ft=ft+1
					else
						sg:AddCard(tc)
						if c:IsHasEffect(511007000)~=nil or rpz:IsHasEffect(511007000)~=nil then
							if not gPend.Filter(tc,e,tp,lscale,rscale) then
								local pg=sg:Filter(aux.TRUE,tc)
								local ct0,ct3,ct4=#pg,pg:FilterCount(Card.IsLocation,nil,LOCATION_HAND+LOCATION_GRAVE),pg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
								sg:Sub(pg)
								ft1=ft1+ct3
								ft2=ft2+ct4
								ft=ft+ct0
							else
								local pg=sg:Filter(aux.NOT(gPend.Filter),nil,e,tp,lscale,rscale)
								sg:Sub(pg)
								if #pg>0 then
									if pg:GetFirst():IsLocation(LOCATION_HAND+LOCATION_GRAVE) then
										ft1=ft1+1
                                    else
                                        ft2=ft2+1
                                    end
									ft=ft+1
								end
							end
						end
						if tc:IsLocation(LOCATION_HAND+LOCATION_GRAVE) then
							ft1=ft1-1
						else
							ft2=ft2+1
						end
						ft=ft-1
					end
				end
				if #sg>0 then
					if not inchain then
						Duel.RegisterFlagEffect(tp,81632992-500,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
					end

					Duel.HintSelection(Group.FromCards(c),true)
					Duel.HintSelection(Group.FromCards(rpz),true)

					local tc=sg:GetFirst()
                    while tc do
                        if gPend.PkTrapFilter(tc) then
                            gPend.PreparePkTrap(tc)
                        end
                        tc=sg:GetNext()
                    end
					Duel.SpecialSummonComplete()
				end
			end