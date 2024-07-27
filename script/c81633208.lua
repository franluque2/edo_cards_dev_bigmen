--Forbidden Memories of Heishin
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
local SUN=2
local MERCURY=3
local VENUS=4
local MOON=5
local MARS=6
local JUPITER=7
local SATURN=8
local URANUS=9
local NEPTUNE=10
local PLUTO=11

local guardianStars={SUN, MERCURY, VENUS, MOON, MARS, JUPITER, SATURN,URANUS, NEPTUNE, PLUTO}
local guardianStarsDisadv={}
guardianStarsDisadv[SUN]=MERCURY
guardianStarsDisadv[MERCURY]=VENUS
guardianStarsDisadv[VENUS]=MOON
guardianStarsDisadv[MOON]=SUN

guardianStarsDisadv[MARS]=NEPTUNE
guardianStarsDisadv[JUPITER]=MARS
guardianStarsDisadv[SATURN]=JUPITER
guardianStarsDisadv[URANUS]=SATURN
guardianStarsDisadv[NEPTUNE]=PLUTO
guardianStarsDisadv[PLUTO]=URANUS

--FILL THIS TABLE PURPLE
local EQSPELLS_TO_GENERATE={242146, 1118137, 1435851, 1557499, 2370081, 3492538, 4614116, 5183693, 6178850, 7625614, 15052462, 17589298, 18937875, 19578592, 21438286, 21900719, 22046459, 24668830, 25769732, 27863269, 27967615, 28106077, 31423101, 32022366, 32268901, 33114323, 34664411, 35220244, 36042825, 36607978, 37120512, 37534148, 37684215, 37820550, 38552107, 39774685, 39897277, 40619825, 41927278, 42149850, 42709949, 46009906, 46910446, 47529357, 51267887, 53363708, 53610653, 54351224, 55226821, 55321970, 56747793, 61127349, 61854111, 64047146, 65169794, 67775894, 68427465, 69243953, 76076738, 77007920, 77027445, 82432018, 82878489, 83225447, 83746708, 84877802, 86198326, 91595718, 95515060, 95638658, 97687912, 98143165, 98252586, 98374133, 98495314, 99597615}
-- JUST THE THING ABOVE

local eqspells={}
eqspells[0]=Group.CreateGroup()
eqspells[1]=Group.CreateGroup()
function s.filltables()
    if #eqspells[0]==0 then
        for i, v in pairs(EQSPELLS_TO_GENERATE) do
            local token1=Duel.CreateToken(0, v)
            eqspells[0]:AddCard(token1)
            local token2=Duel.CreateToken(1, v)
            eqspells[1]:AddCard(token2)


        end
    end
end

function s.getguardianstar(c)
    return c:GetFlagEffectLabel(id)
end

function s.registerguardianstar(c,e, starval)
    if not (c:IsOnField() and c:IsFaceup()) then return end
    c:ResetFlagEffect(id)
    c:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,starval))
    c:SetFlagEffectLabel(id, starval)
end

function s.isguardianstardisadv(c, starval)
    return c:IsOnField() and c:IsFaceup() and guardianStarsDisadv[s.getguardianstar(c)]==starval
end

function s.isguardianstaradv(c, starval)
    return c:IsOnField() and c:IsFaceup() and guardianStarsDisadv[starval]==s.getguardianstar(c)
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
		--bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)
        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e7:SetCode(EVENT_SUMMON_SUCCESS)
        e7:SetCondition(s.spcon)
        e7:SetOperation(s.spop)
        Duel.RegisterEffect(e7,tp)

        local e8=e7:Clone()
        e8:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(e8,tp)

        local e9=e7:Clone()
        e9:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
        Duel.RegisterEffect(e9,tp)

        --draw till 5
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_DRAW_COUNT)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetTargetRange(1,0)
        e3:SetValue(s.getcarddraw)
        Duel.RegisterEffect(e3,tp)

        local e17=e7:Clone()
        e17:SetCondition(s.spcon2)
        e17:SetOperation(s.spop2)
        Duel.RegisterEffect(e17, tp)

        local e18=e17:Clone()
        e18:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(e18,tp)

        local e19=e17:Clone()
        e19:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
        Duel.RegisterEffect(e19,tp)


        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_SUMMON_PROC)
        e5:SetTargetRange(LOCATION_HAND,0)
        e5:SetCondition(s.ntcon)
        e5:SetTarget(aux.FieldSummonProcTg(s.nttg))
        Duel.RegisterEffect(e5,tp)


    
        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_CANNOT_TRIGGER)
        e6:SetTargetRange(LOCATION_MZONE,0)
        Duel.RegisterEffect(e6, tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_IMMUNE_EFFECT)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetValue(s.efilter)
        Duel.RegisterEffect(e2, tp)

        local e13=Effect.CreateEffect(e:GetHandler())
        e13:SetType(EFFECT_TYPE_FIELD)
        e13:SetCode(EFFECT_UPDATE_ATTACK)
        e13:SetTargetRange(LOCATION_MZONE,0)
        e13:SetCondition(s.atkcon)
        e13:SetValue(s.atkval)
        Duel.RegisterEffect(e13, tp)

        local e14=e13:Clone()
        e14:SetCode(EFFECT_UPDATE_DEFENSE)
        Duel.RegisterEffect(e14,tp)

        local e15=Effect.CreateEffect(e:GetHandler())
        e15:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e15:SetCode(EVENT_BATTLED)
        e15:SetCondition(s.racon)
        e15:SetOperation(s.raop)
        Duel.RegisterEffect(e15, tp)

        --give infinite hand size
        local e27=Effect.CreateEffect(e:GetHandler())
        e27:SetType(EFFECT_TYPE_FIELD)
        e27:SetCode(EFFECT_HAND_LIMIT)
        e27:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e27:SetTargetRange(1,0)
        e27:SetValue(100)
        Duel.RegisterEffect(e27,tp)
        
	end
	e:SetLabel(1)
end


function s.racon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()
end
function s.raop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
    local atk=Duel.GetAttacker()
    if not atk:IsControler(e:GetHandlerPlayer()) then
        atk=Duel.GetAttackTarget()
        d=Duel.GetAttacker()
    end
	if not d:IsRelateToBattle() or d:IsFacedown() then return end
    local val=0
    if atk:IsPosition(POS_FACEUP_ATTACK) then
        val=atk:GetAttack()
    else
        val=atk:GetDefense()
    end
    if d:IsPosition(POS_FACEUP_ATTACK) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-val)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        d:RegisterEffect(e1)
    else
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_DEFENSE)
        e1:SetValue(-val)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        d:RegisterEffect(e1)
    end
    if Card.IsAttack(d, 0) or Card.IsDefense(d, 0) then
        Duel.Destroy(d, REASON_RULE)
    end
end

function s.atkcon(e)
	s[0]=false
    s[1]=false
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end

function s.atkval(e,c)
	local d=Duel.GetAttackTarget()
    local atk=Duel.GetAttacker()
    if not atk:IsControler(e:GetHandlerPlayer()) then
        atk=Duel.GetAttackTarget()
        d=Duel.GetAttacker()
    end
	if s[0] or s.isguardianstardisadv(d, s.getguardianstar(atk)) then
		s[0]=true
		return 1000
    elseif s[1] or s.isguardianstardisadv(atk, s.getguardianstar(d)) then
        s[1]=true
        return -1000

    else return 0 end
end


function s.efilter(e,re, c)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_MONSTER)
		and re:IsActivated() and re:GetOwner():IsOnField() and s.isguardianstardisadv(re:GetOwner(), s.getguardianstar(c))
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsLevelAbove(5)
end

function s.getcarddraw(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0) < 5 then
		return 5-Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)
	else
		return 1
end
end

function s.spfilter(c, tp)
    return c:IsOnField() and c:IsFaceup() and c:GetFlagEffect(id)==0 and not c:IsControler(tp)
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter, 1, nil, 1-tp)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)

    local g=eg:Filter(s.spfilter, nil, 1-tp)

    for tc in g:Iter() do
        local starval1=Duel.GetRandomNumber(1, #guardianStars)
        local starval2=Duel.GetRandomNumber(1, #guardianStars)
        while starval2==starval1 do
            starval2=Duel.GetRandomNumber(1, #guardianStars)
        end
        local starval3=Duel.GetRandomNumber(1, #guardianStars)
        while (starval3==starval1) or (starval3==starval2) do
            starval3=Duel.GetRandomNumber(1, #guardianStars)
        end
        local starval4=Duel.GetRandomNumber(1, #guardianStars)
        while (starval4==starval1) or (starval4==starval2) or (starval4==starval3) do
            starval4=Duel.GetRandomNumber(1, #guardianStars)
        end

        local optionstable={}
        for index, value in ipairs(guardianStars) do
            local waspicked=(index==starval1)or(index==starval2)or(index==starval3)or(index==starval4)
            optionstable[index]={waspicked, aux.Stringid(id, value)}
        end

        local pickedstarval=Duel.SelectEffect(tp, table.unpack(optionstable))

        s.registerguardianstar(tc,e, guardianStars[pickedstarval])
    end
end



function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter, 1, nil, tp)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)

    local g=eg:Filter(s.spfilter, nil, tp)

    for tc in g:Iter() do
        local starval=Duel.GetRandomNumber(1, #guardianStars)
        s.registerguardianstar(tc,e, guardianStars[starval])
    end
end




function s.cannotsummonfilter(c)
    return c:IsMonster() and not c:IsSummonableCard()
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

    local rituals=Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_ALL, 0, nil, TYPE_RITUAL)
    for tc in rituals:Iter() do
        if tc:IsMonster() then
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_SPSUMMON_PROC)
        e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM+EFFECT_FLAG_UNCOPYABLE)
        e1:SetTargetRange(POS_FACEUP_ATTACK,0)
        e1:SetRange(LOCATION_HAND)
        e1:SetCondition(s.spcon3)
        e1:SetValue(1)
        tc:RegisterEffect(e1)

        local e2=Effect.CreateEffect(tc)
        e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_SPSUMMON_SUCCESS)
        e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
        e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1) end)
        e2:SetOperation(s.sumop)
        tc:RegisterEffect(e2)

            

        end

    end

    local fusions=Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_EXTRA, 0, nil, TYPE_FUSION)
    for tc in fusions:Iter() do
        Fusion.AddProcMixN(tc,true,true,s.sharesmatfilter,2)
        Fusion.AddContactProc(tc,function(tp) return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,nil) end,function(g) Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL) end,true)

    end

    local nomis=Duel.GetMatchingGroup(s.cannotsummonfilter, tp, LOCATION_HAND|LOCATION_DECK, 0, nil)
    for tc in nomis:Iter() do
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_SPSUMMON_PROC)
        e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM+EFFECT_FLAG_UNCOPYABLE)
        e1:SetTargetRange(POS_FACEUP_ATTACK,0)
        e1:SetRange(LOCATION_HAND)
        e1:SetCondition(s.spcon3)
        e1:SetValue(1)
        tc:RegisterEffect(e1)

        local e2=Effect.CreateEffect(tc)
        e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_SPSUMMON_SUCCESS)
        e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
        e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1) end)
        e2:SetOperation(s.sumop)
        tc:RegisterEffect(e2)
    end

    s.filltables()
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e2,tp)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetTarget(function(e,c) return c:IsType(TYPE_RITUAL) end)
    Duel.RegisterEffect(e3,tp)

end

function s.sharesmatfilter(c,fc,sumtype,tp)
	return c:IsMonsterCard() and (c:IsRace(fc:GetRace(),fc,sumtype,tp) or c:IsAttribute(fc:GetAttribute(),fc,sumtype,tp))
end

function s.spcon3(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function s.fueqspellfilter(c)
    return c:IsSpell() and c:IsType(TYPE_EQUIP) and c:IsFaceup()
end

function s.advfusion(c, guardianstar)
    return c:IsType(TYPE_FUSION) and s.isguardianstaradv(c,guardianstar)
end

function s.atfusdisadv(c)
    return c:IsFaceup() and Duel.IsExistingMatchingCard(s.advfusion, c:GetControler(), 0, LOCATION_MZONE, 1, nil, s.getguardianstar(c))
end

function s.discardspellfilter(c)
    return c:IsSpellTrap() and c:IsDiscardable(REASON_COST)
end

function s.discardmonfilter(c)
    return c:IsMonster() and c:IsDiscardable(REASON_COST)
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.fueqspellfilter,tp,LOCATION_SZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.discardspellfilter,tp,LOCATION_HAND,0,1,nil)
            and Duel.IsExistingMatchingCard(s.discardmonfilter,tp,LOCATION_HAND,0,1,nil)



--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

    local b1=Duel.GetFlagEffect(tp,id+1)==0
    and Duel.IsExistingMatchingCard(s.fueqspellfilter,tp,LOCATION_SZONE,0,1,nil)
                and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)

    local b2=Duel.GetFlagEffect(tp,id+2)==0
    and Duel.IsExistingMatchingCard(s.discardspellfilter,tp,LOCATION_HAND,0,1,nil)
    and Duel.IsExistingMatchingCard(s.discardmonfilter,tp,LOCATION_HAND,0,1,nil)
    

--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,1)},
								  {b2,aux.Stringid(id,0)})
	op=op-1

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end



function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)

    local tc=Duel.SelectMatchingCard(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1,1,false,nil):GetFirst()
    if tc then
        local optionstable={}
        for index, value in ipairs(guardianStars) do
            optionstable[index]={true, aux.Stringid(id, value)}
        end

        local pickedstarval=Duel.SelectEffect(tp, table.unpack(optionstable))
        s.registerguardianstar(tc,e,guardianStars[pickedstarval])
    end


--sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
	Duel.RegisterFlagEffect(tp,id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end


function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
    local tc1=Duel.SelectMatchingCard(tp, s.discardmonfilter, tp, LOCATION_HAND, 0,1,1,false,nil)
    local tc2=Duel.SelectMatchingCard(tp, s.discardspellfilter, tp, LOCATION_HAND, 0,1,1,false,nil)
    local g=Group.CreateGroup()
    g:AddCard(tc1)
    g:AddCard(tc2)
    Duel.SendtoGrave(g, REASON_COST)

    local numval1=Duel.GetRandomNumber(1, #EQSPELLS_TO_GENERATE)
    local numval2=Duel.GetRandomNumber(1, #EQSPELLS_TO_GENERATE)
    while numval2==numval1 do
        numval2=Duel.GetRandomNumber(1, #EQSPELLS_TO_GENERATE)
    end
    local numval3=Duel.GetRandomNumber(1, #EQSPELLS_TO_GENERATE)
    while (numval3==numval1) or (numval3==numval2) do
        numval3=Duel.GetRandomNumber(1, #EQSPELLS_TO_GENERATE)
    end
    local numval4=Duel.GetRandomNumber(1, #EQSPELLS_TO_GENERATE)
    while (numval4==numval1) or (numval4==numval2) or (numval4==numval3) do
        numval4=Duel.GetRandomNumber(1, #EQSPELLS_TO_GENERATE)
    end
    local numval5=Duel.GetRandomNumber(1, #EQSPELLS_TO_GENERATE)
    while (numval5==numval1) or (numval5==numval2) or (numval5==numval3) or (numval5==numval4) do
        numval5=Duel.GetRandomNumber(1, #EQSPELLS_TO_GENERATE)
    end

    local pickg=Group.CreateGroup()
    pickg:AddCard(Group.TakeatPos(eqspells[tp], numval1-1))
    pickg:AddCard(Group.TakeatPos(eqspells[tp], numval2-1))
    pickg:AddCard(Group.TakeatPos(eqspells[tp], numval3-1))
    pickg:AddCard(Group.TakeatPos(eqspells[tp], numval4-1))
    pickg:AddCard(Group.TakeatPos(eqspells[tp], numval5-1))

    local tc=pickg:Select(tp, 1,1,nil):GetFirst()
    if tc then
        local token=Duel.CreateToken(tp, tc:GetOriginalCode())
        Duel.SendtoHand(token, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, token)
    end
	--Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
