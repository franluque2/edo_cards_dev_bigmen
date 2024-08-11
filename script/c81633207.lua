--Forbidden Memories of Nitemare
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

function s.cannotsummonfilter(c)
    return c:IsMonster() and not c:IsSummonableCard()
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
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.GetActivityCount(e:GetHandlerPlayer(),ACTIVITY_NORMALSUMMON)==0
end

function s.furitualfilter(c)
    return c:IsMonster() and c:IsType(TYPE_RITUAL) and c:IsFaceup()
end

function s.advfusion(c, guardianstar)
    return c:IsType(TYPE_FUSION) and s.isguardianstaradv(c,guardianstar)
end

function s.atfusdisadv(c)
    return c:IsFaceup() and Duel.IsExistingMatchingCard(s.advfusion, c:GetControler(), 0, LOCATION_MZONE, 1, nil, s.getguardianstar(c))
end

--effects to activate during the main phase go here
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	--checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0  then return end
	--Boolean checks for the activation condition: b1, b2

--do bx for the conditions for each effect, and at the end add them to the return
	local b1=Duel.GetFlagEffect(tp,id+1)==0
			and Duel.IsExistingMatchingCard(s.furitualfilter,tp,LOCATION_MZONE,0,1,nil)
						and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+2)==0
			and Duel.IsExistingMatchingCard(s.atfusdisadv,tp,0,LOCATION_MZONE,1,nil)


--return the b1 or b2 or .... in parenthesis at the end
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--"pop" the skill card
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:

--copy the bxs from above

    local b1=Duel.GetFlagEffect(tp,id+1)==0
    and Duel.IsExistingMatchingCard(s.furitualfilter,tp,LOCATION_MZONE,0,1,nil)
                and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)

    local b2=Duel.GetFlagEffect(tp,id+2)==0
    and Duel.IsExistingMatchingCard(s.atfusdisadv,tp,0,LOCATION_MZONE,1,nil)


--effect selector
	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								  {b2,aux.Stringid(id,1)})
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

    local tc=Duel.SelectMatchingCard(tp, s.atfusdisadv, tp, 0, LOCATION_MZONE, 1,1,false,nil)
    if tc then
        Duel.Destroy(tc, REASON_RULE)
    end
	--sets the opd
	Duel.RegisterFlagEffect(tp,id+2,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
end
