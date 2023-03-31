--Mysterious Goha President
Duel.LoadScript("big_aux.lua")


local s, id = GetID()
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
        bRush.addrules()(e, tp, eg, ep, ev, re, r, rp)

        local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_SET_BASE_DEFENSE)
		e4:SetTargetRange(LOCATION_MZONE,0)
        e4:SetCondition(s.defcon)
		e4:SetTarget(aux.TargetBoolFunction(s.fusionfilter))
		e4:SetValue(3000)
		Duel.RegisterEffect(e4,tp)
    end
    e:SetLabel(1)
end

function s.milshieldfilter(c)
    return c:IsCode(32012841) and c:IsFaceup()
end

function s.defcon(e)
    return Duel.IsExistingMatchingCard(s.milshieldfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.fusionfilter(c)
	return c:IsType(TYPE_FUSION)
end


function s.flipcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentChain() == 0 and Duel.GetTurnCount() == 1
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    Duel.Hint(HINT_CARD, tp, id)

    --start of duel effects go here

    s.startofdueleff(e, tp, eg, ep, ev, re, r, rp)

    Duel.RegisterFlagEffect(ep, id, 0, 0, 0)
end

function s.startofdueleff(e, tp, eg, ep, ev, re, r, rp)

end

function s.isswordsman(c, code,e,tp)
    return c:IsCode(160201007, 160305015) and not c:IsCode(code)
end

function s.istributableswordsman(c,e,tp)
    return c:IsCode(160201007, 160305015) and
    Duel.IsExistingMatchingCard(s.isswordsman, c:GetControler(), LOCATION_GRAVE, 0, 1, nil, c:Code(),e,tp) and
    c:IsReleasable()
end

function s.issword(c, code,e,tp)
    return c:IsCode(160009008, 160009007, 160009009) and not c:IsCode(code)
end

function s.istributablesword(c,e,tp)
    return c:IsCode(160009008, 160009007, 160009009) and
        Duel.IsExistingMatchingCard(s.issword, c:GetControler(), LOCATION_GRAVE, 0, 1, nil, c:Code(),e,tp) and
    c:IsReleasable()
end

function s.fumilfilter(c)
    return c:IsCode(32012841) and c:IsPosition(POS_FACEUP_ATTACK)
end

function s.sshieldfilter(c)
    return c:IsCode(160004052) and c:IsSSetable()
end

function s.istributableswordorman(c,e,tp)
    return s.istributablesword(c,e,tp) or s.istributableswordsman(c,e,tp)
end

--effects to activate during the main phase go here
function s.flipcon2(e, tp, eg, ep, ev, re, r, rp)
    --OPT check
    --checks to not let you activate anything if you can't, add every flag effect used for opt/opd here
    if Duel.GetFlagEffect(tp, id + 1) > 0 and Duel.GetFlagEffect(tp, id + 2) > 0 then return end
    --Boolean checks for the activation condition: b1, b2

    --do bx for the conditions for each effect, and at the end add them to the return
    local b1 = Duel.GetFlagEffect(tp, id + 1) == 0
        and
        (Duel.IsExistingMatchingCard(s.istributableswordsman, tp, LOCATION_MZONE, 0, 1, nil,e,tp) or Duel.IsExistingMatchingCard(s.istributablesword, tp, LOCATION_MZONE, 0, 1, nil,e,tp))
        and Duel.IsPlayerCanDiscardDeck(tp, 1)

    local b2 = Duel.GetFlagEffect(tp, id + 2) == 0
        and Duel.IsExistingMatchingCard(s.fumilfilter, tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.sshieldfilter, tp, LOCATION_GRAVE, 0, 1, nil)
        and Duel.GetLocationCount(tp, LOCATION_SZONE - LOCATION_FZONE) > 0


    --return the b1 or b2 or .... in parenthesis at the end
    return aux.CanActivateSkill(tp) and (b1 or b2)
end

function s.flipop2(e, tp, eg, ep, ev, re, r, rp)
    --"pop" the skill card
    Duel.Hint(HINT_CARD, tp, id)
    --Boolean check for effect 1:

    --copy the bxs from above
    local b1 = Duel.GetFlagEffect(tp, id + 1) == 0
        and
        (Duel.IsExistingMatchingCard(s.istributableswordsman, tp, LOCATION_MZONE, 0, 1, nil,e,tp) or Duel.IsExistingMatchingCard(s.istributablesword, tp, LOCATION_MZONE, 0, 1, nil,e,tp))
        and Duel.IsPlayerCanDiscardDeck(tp, 1)

    local b2 = Duel.GetFlagEffect(tp, id + 2) == 0
        and Duel.IsExistingMatchingCard(s.fumilfilter, tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.sshieldfilter, tp, LOCATION_GRAVE, 0, 1, nil)
        and Duel.GetLocationCount(tp, LOCATION_SZONE - LOCATION_FZONE) > 0


    --effect selector
    local op = Duel.SelectEffect(tp, { b1, aux.Stringid(id, 0) },
        { b2, aux.Stringid(id, 3) })
    op = op - 1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

    if op == 0 then
        s.operation_for_res0(e, tp, eg, ep, ev, re, r, rp)
    elseif op == 1 then
        s.operation_for_res1(e, tp, eg, ep, ev, re, r, rp)
    end
end

function s.operation_for_res0(e, tp, eg, ep, ev, re, r, rp)
    Duel.DiscardDeck(tp, 1, REASON_RULE)
    local tribute = Duel.SelectMatchingCard(tp, s.istributableswordorman, tp, LOCATION_MZONE, 0, 1, 1, false, nil,e,tp)
    if s.istributableswordsman(tribute:GetFirst(),e,tp) then
        Duel.Release(tribute, REASON_RULE)
        local restarget = Duel.SelectMatchingCard(tp, s.isswordsman, tp, LOCATION_GRAVE, 0, 1, 1, false, nil,
        tribute:GetFirst():Code(),e,tp)
        if restarget then
            Duel.SpecialSummon(restarget, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
        end
    else
        Duel.Release(tribute, REASON_RULE)
        local restarget = Duel.SelectMatchingCard(tp, s.issword, tp, LOCATION_GRAVE, 0, 1, 1, false, nil,
        tribute:GetFirst():Code(),e,tp)
        if restarget then
            Duel.SpecialSummon(restarget, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
        end
    end

    --sets the opt (replace RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END with 0 to make it an opd)
    Duel.RegisterFlagEffect(tp, id + 1, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
end

function s.operation_for_res1(e, tp, eg, ep, ev, re, r, rp)
    local sshield = Duel.SelectMatchingCard(tp, s.sshieldfilter, tp, LOCATION_GRAVE, 0, 1, 1, false, nil)
    if sshield then
        Duel.SSet(tp, sshield)
        Duel.ConfirmCards(1 - tp, sshield)

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		sshield:GetFirst():RegisterEffect(e1,true)
    end
    --sets the opd
    Duel.RegisterFlagEffect(tp, id + 2, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
end
