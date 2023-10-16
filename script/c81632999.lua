--The Heroic Society
Duel.LoadScript("big_aux.lua")

EHERO_SPARKMAN = 20721928
EHERO_CLAYMAN = 84327329
EHERO_BURST = 58932615
EHERO_AVIAN = 21844576
EHERO_BLADEDGE = 59793705
EHERO_WILDHEART = 86188410
EHERO_BUBBLEMAN = 79979666
EHERO_NEOS = 89943723
SPARK_BLASTER = 97362768



local s, id = GetID()


s.cardsperhero = {}
s.cardsperhero[0]={}
s.cardsperhero[1]={}


s.cardsperhero[0][EHERO_SPARKMAN] = { SPARK_BLASTER }
s.cardsperhero[1][EHERO_SPARKMAN] = { SPARK_BLASTER }
s.cardsperhero[0][EHERO_CLAYMAN] = { 511000484, 511000998, 22479888 }
s.cardsperhero[1][EHERO_CLAYMAN] = { 511000484, 511000998, 22479888 }
s.cardsperhero[0][EHERO_BURST] = { 27191436, 511000021 }
s.cardsperhero[1][EHERO_BURST] = { 27191436, 511000021 }
s.cardsperhero[0][EHERO_AVIAN] = { 19394153, 511000488, 71060915 }
s.cardsperhero[1][EHERO_AVIAN] = { 19394153, 511000488, 71060915 }
s.cardsperhero[0][EHERO_BLADEDGE] = { 84361420 }
s.cardsperhero[1][EHERO_BLADEDGE] = { 84361420 }
s.cardsperhero[0][EHERO_WILDHEART] = { 29612557, 511001353 }
s.cardsperhero[1][EHERO_WILDHEART] = { 29612557, 511001353 }
s.cardsperhero[0][EHERO_BUBBLEMAN] = { 05285665, 61968753, 80075749, 53586134, 511002154}
s.cardsperhero[1][EHERO_BUBBLEMAN] = { 05285665, 61968753, 80075749, 53586134, 511002154}
s.cardsperhero[0][EHERO_NEOS] = { 05126490, 69884162, 85840608, 10186633, 14088859, 16169772, 35255456, 35255456, 41933425, 52098461, 80170678, 100000551, 18302224, 46570372, 52553471, 73239437, 89058026, 11913700, 47274077, 42015635, 74414855, 75047173, 100000102, 100000553, 100000557 }
s.cardsperhero[1][EHERO_NEOS] = { 05126490, 69884162, 85840608, 10186633, 14088859, 16169772, 35255456, 41933425, 52098461, 80170678, 100000551, 18302224, 46570372, 52553471, 73239437, 89058026, 11913700, 47274077, 42015635, 74414885, 75047173, 100000102, 100000553, 100000557 }

function s.initial_effect(c)
    --Activate Skill
    aux.AddSkillProcedure(c, 2, false, nil, nil)
    local e1 = Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_STARTUP)
    e1:SetCountLimit(1)
    e1:SetRange(0x5f)
    e1:SetLabel(0)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
    aux.AddSkillProcedure(c, 2, false, s.flipcon2, s.flipop2)
end

function s.op(e, tp, eg, ep, ev, re, r, rp)
    if e:GetLabel() == 0 then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PREDRAW)
        e1:SetCondition(s.flipcon)
        e1:SetOperation(s.flipop)
        Duel.RegisterEffect(e1, tp)

        --other passive duel effects go here

        --uncomment (remove the --) the line below to make it a rush skill
        --bRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

        local e2 = Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE + PHASE_STANDBY)
        e2:SetCondition(s.flipconsb)
        e2:SetOperation(s.flipopsb)
        Duel.RegisterEffect(e2, tp)

        local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetCondition(s.descon)
		e3:SetOperation(s.desop)
		Duel.RegisterEffect(e3,tp)

        local e9=Effect.CreateEffect(e:GetHandler())
		e9:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e9:SetCode(EVENT_SPSUMMON_SUCCESS)
		e9:SetOperation(s.mreborncheck)
		Duel.RegisterEffect(e9,tp)
	
	
		local e10=Effect.CreateEffect(e:GetHandler())
		e10:SetType(EFFECT_TYPE_FIELD)
		e10:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		e10:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e10:SetTarget(s.rmtarget)
		e10:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e10:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e10,tp)

		local e11=Effect.CreateEffect(e:GetHandler())
		e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e11:SetCode(EVENT_CHAINING)
		e11:SetOperation(s.chainop)
		Duel.RegisterEffect(e11,tp)


    end
    e:SetLabel(1)
end

function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsMonster() then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp~=rp and not e:GetHandler():IsCode(100302002)
end

function s.mreborncheck(e,tp,eg,ev,ep,re,r,rp)
	if not re then return end
	if (eg:GetFirst():IsCode(100302002) and eg:GetFirst():IsPreviousLocation(LOCATION_GRAVE)) then
		local ec=eg:GetFirst()
		while ec do
			ec:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,0)
			ec=eg:GetNext()
		end
	end
end

function s.rmtarget(e,c)
	if not c:IsLocation(0x80) and (c:GetFlagEffect(id+1)>0) then
		return true
	else
		return false
	end
end



function s.flipcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentChain() == 0 and Duel.GetTurnCount() == 1
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    Duel.Hint(HINT_CARD, tp, id)

    --start of duel effects go here
end

function s.flipconsb(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentChain() == 0 and Duel.GetCurrentPhase() == PHASE_STANDBY and Duel.GetTurnPlayer() == tp
        and Duel.GetFlagEffect(tp, id) < 6 and Duel.GetFlagEffect(tp, id + 1) == 0
end

function s.flipopsb(e, tp, eg, ep, ev, re, r, rp)
    if (Duel.GetFlagEffect(tp, id)) > 0 then
        Duel.Hint(HINT_CARD, tp, id)
    end

    if Duel.GetFlagEffect(tp, id) > 1 then
        if Duel.GetFlagEffect(tp, id) > 2 then
            if Duel.GetFlagEffect(tp, id) > 3 then
                if Duel.GetFlagEffect(tp, id) > 4 then
                    if Duel.GetFlagEffect(tp, id) == 5 then
                        local gencard = Duel.CreateToken(tp, 00191749)
                        Duel.SendtoHand(gencard, tp, REASON_RULE)
                        Duel.ConfirmCards(1 - tp, gencard)
                    end
                else
                    local gencard = Duel.CreateToken(tp, 63703130)
                    Duel.SendtoHand(gencard, tp, REASON_RULE)
                    Duel.ConfirmCards(1 - tp, gencard)
                end
            else
                local gencard = Duel.CreateToken(tp, 37318031)
                Duel.SendtoHand(gencard, tp, REASON_RULE)
                Duel.ConfirmCards(1 - tp, gencard)
            end
        else
            local gencard = Duel.CreateToken(tp, 00213326)
            Duel.SendtoHand(gencard, tp, REASON_RULE)
            Duel.ConfirmCards(1 - tp, gencard)
        end
    else
        if Duel.GetFlagEffect(tp, id) == 1 then
            local gencard = Duel.CreateToken(tp, 74825788)
            Duel.SendtoHand(gencard, tp, REASON_RULE)
            Duel.ConfirmCards(1 - tp, gencard)
        end
    end

    Duel.RegisterFlagEffect(tp, id + 1, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
end

function s.isvalidvanilla(c)
    return c:IsFaceup() and (s.cardsperhero[c:GetControler()][c:GetCode()] ~= nil) and ((#s.cardsperhero[c:GetControler()][c:GetCode()]>0))
end

function s.wingmanfilter(c)
    return c:IsFaceup() and c:IsCode(35809262)
end

--effects to activate during the main phase go here
function s.flipcon2(e, tp, eg, ep, ev, re, r, rp)
    --OPT check
    --checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
    if Duel.GetFlagEffect(tp, id + 2) > 0 and Duel.GetFlagEffect(tp, id + 3) > 0 then return end
    --Boolean checks for the activation condition: b1, b2

    --do bx for the conditions for each effect, and at the end add them to the return
    local b1 = Duel.GetFlagEffect(tp, id + 2) == 0
        and Duel.IsExistingMatchingCard(s.isvalidvanilla, tp, LOCATION_MZONE, 0, 1, nil)

        local b2 = Duel.GetFlagEffect(tp, id + 3) == 0
        and (Duel.GetFlagEffect(tp, id + 4) == 0 or Duel.GetFlagEffect(tp, id+5)==0)
        and Duel.IsExistingMatchingCard(s.wingmanfilter, tp, LOCATION_MZONE, 0, 1, nil, tp)


    --return the b1 or b2 or .... in parenthesis at the end
    return aux.CanActivateSkill(tp) and (b1 or b2)
end

function s.flipop2(e, tp, eg, ep, ev, re, r, rp)
    --"pop" the skill card
    Duel.Hint(HINT_CARD, tp, id)
    --Boolean check for effect 1:

    --copy the bxs from above

    local b1 = Duel.GetFlagEffect(tp, id + 2) == 0
        and Duel.IsExistingMatchingCard(s.isvalidvanilla, tp, LOCATION_MZONE, 0, 1, nil)

    local b2 = Duel.GetFlagEffect(tp, id + 3) == 0
        and (Duel.GetFlagEffect(tp, id + 4) == 0 or Duel.GetFlagEffect(tp, id+5)==0)
        and Duel.IsExistingMatchingCard(s.wingmanfilter, tp, LOCATION_MZONE, 0, 1, nil, tp)

    --effect selector
    local op = Duel.SelectEffect(tp, { b1, aux.Stringid(id, 0) },
        { b2, aux.Stringid(id, 1) })
    op = op - 1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

    if op == 0 then
        s.operation_for_res0(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 1 then
        s.operation_for_res1(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.operation_for_res0(e, tp, eg, ep, ev, re, r, rp)

    local hero=Duel.SelectMatchingCard(tp, s.isvalidvanilla, tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
    if hero then
        local cards=Group.CreateGroup()

        for i,v in ipairs(s.cardsperhero[tp][hero:GetCode()]) do
            local card=Duel.CreateToken(tp, v)
            cards:AddCard(card)
        end

        local ctoadd=cards:Select(tp, 1, 1,false,nil):GetFirst()

        for i,v in ipairs(s.cardsperhero[tp][hero:GetCode()]) do
            if v==ctoadd:GetCode() then
                table.remove(s.cardsperhero[tp][hero:GetCode()],i)
            end
        end

        Duel.SendtoHand(ctoadd, tp, REASON_RULE)
    end
    Duel.RegisterFlagEffect(tp, id + 2, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
end

function s.operation_for_res1(e, tp, eg, ep, ev, re, r, rp)

    local b1 = Duel.GetFlagEffect(tp, id + 4) == 0

    local b2 = Duel.GetFlagEffect(tp, id+5)==0

    local op = Duel.SelectEffect(tp, { b1, aux.Stringid(id, 2) },
        { b2, aux.Stringid(id, 3) })
    op = op - 1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

    if op == 0 then
        local card=Duel.CreateToken(tp, 11881272)
        Duel.SendtoHand(card, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, card)
        Duel.RegisterFlagEffect(tp, id + 4, 0, 0, 0)
        
    elseif op == 1 then

        local card=Duel.CreateToken(tp, 40522482)
        Duel.SendtoHand(card, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, card)
        Duel.RegisterFlagEffect(tp, id + 5, 0, 0, 0)
    end
    

    Duel.RegisterFlagEffect(tp, id + 3, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
end

function s.cfilter1(c,e,tp)
	return c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsCode(57116033) end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetFlagEffect(tp, id+6)<3) and eg:IsExists(s.cfilter1,1,nil,e,tp)
end
--

function s.desop(e,tp,eg,ep,ev,re,r,rp)
		
		if Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
            Duel.Hint(HINT_CARD,tp,id)
            
            local sabatiel=Duel.CreateToken(tp, 80831721)
            Duel.SendtoHand(sabatiel, tp, REASON_RULE)
			Duel.ConfirmCards(1-tp, sabatiel)

			Duel.RegisterFlagEffect(tp, id+6, 0, 0, 0)
		end

end