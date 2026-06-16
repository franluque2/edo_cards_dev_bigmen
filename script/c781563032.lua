--Geschichte der Besessenheit
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

    aux.GlobalCheck(s, function()
        s.used_this_skill = {}
        s.used_this_skill[0] = false
        s.used_this_skill[1] = false

    aux.AddValuesReset(function()
        s.used_this_skill[0] = false
        s.used_this_skill[1] = false

		end)

    end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,s.flipconactive, s.flipopactive, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

function s.shufflesuperpolyfilter(c)
    return c:IsCode(CARD_SUPER_POLYMERIZATION) and c:IsAbleToDeck()
end

function s.addmaturechroniclefilter(c)
    return c:IsCode(92650749) and c:IsAbleToHand()
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    return (not s.used_this_skill[e:GetHandlerPlayer()])  and aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.addmaturechroniclefilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.shufflesuperpolyfilter, tp, LOCATION_HAND, 0, 1, nil)
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    s.used_this_skill[e:GetHandlerPlayer()] = true
    Duel.Hint(HINT_CARD, tp, id)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local tc=Duel.SelectMatchingCard(tp, s.shufflesuperpolyfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
    if #tc>0 then
        Duel.ConfirmCards(1-tp, tc)
        Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp, s.addmaturechroniclefilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, 1, nil)
    if #g>0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()


    --Negate the effects of "Nightmare Pain" and "Geistgrinder Golem", during the damage step only.
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetTargetRange(LOCATION_ONFIELD, LOCATION_ONFIELD)
    e1:SetTarget(function(ef, _c) return _c:IsCode(65261141, 26913989) end)
    e1:SetCondition(function() local ph=Duel.GetCurrentPhase()
        return (ph == PHASE_DAMAGE or ph == PHASE_DAMAGE_CAL) end)
    e1:SetValue(1)
    Duel.RegisterEffect(e1, tp)

    --After your "Spirit of Yubel" battles an opponent's attacking monster, negate its effects, until the end of this turn.
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    Duel.RegisterEffect(e2,tp)

    --You cannot activate "Super Polymerization", unless it has been added to your hand by the effect of "Mature Chronicle".
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetValue(function(_, _re, _tp) return _re:IsHasType(EFFECT_TYPE_ACTIVATE) and _re:GetHandler():IsCode(CARD_SUPER_POLYMERIZATION) and (not (_re:GetHandler():GetFlagEffect(id)>0)) end)
    Duel.RegisterEffect(e3,tp)

    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_TO_HAND)
    e4:SetCondition(function(_,_,_eg,_,_,_re,_,_) return _eg:IsExists(Card.IsCode, 1, nil, CARD_SUPER_POLYMERIZATION) and _re and _re:GetHandler():IsCode(92650749) end)
    e4:SetOperation(function(_,_,_eg,_,_,_re,_,_)
        local g=_eg:Filter(Card.IsCode, nil, CARD_SUPER_POLYMERIZATION)
        for tc in aux.Next(g) do
            tc:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD, 0, 1)
        end
    end)
    Duel.RegisterEffect(e4, tp)

    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_ADJUST)
    e5:SetCondition(function (_,_tp)
        return Duel.IsExistingMatchingCard(s.nottaggeddefenderfilter, _tp, LOCATION_ALL, 0, 1, nil)     
    end)
    e5:SetOperation(s.rewritedefendersop)
    Duel.RegisterEffect(e5, tp)


    -- At the start of each turn after the first, your opponent declares 1 Monster Card name
    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_PREDRAW)
    e6:SetCountLimit(1)
    e6:SetCondition(function() return Duel.GetTurnCount()>1 end)
    e6:SetOperation(s.declareop)
    Duel.RegisterEffect(e6, tp)

end

function s.nottaggeddefenderfilter(c)
    return c:IsCode(47172959) and c:GetFlagEffect(id)==0
end

function s.rewritedefendersop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.nottaggeddefenderfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)
        	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	tc:RegisterEffect(e1)

    end
end

function s.splimit(e,se,sp,st)
	local code=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE)
	return se:GetHandler():IsCode(CARD_SUPER_POLYMERIZATION) or code==CARD_SUPER_POLYMERIZATION
end

function s.negtg(e,c)
    local bc=Duel.GetAttacker()
    local ac=Duel.GetAttackTarget()

	if ac and s.myspiritfilter(ac,e:GetHandlerPlayer()) then
		return true
	end
	return false
end

function s.myspiritfilter(c,tp)
    return c:IsCode(90829280) and c:IsFaceup() and c:IsControler(tp)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ac=Duel.GetAttackTarget()

    local tc=ac

    if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1,true)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2,true)
    end
end

function s.declareop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,tp,id)
	local ac=Duel.AnnounceCard(1-tp,TYPE_MONSTER)

    --this turn, monsters they control with that name are unaffected by your card effects
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetTargetRange(0, LOCATION_MZONE)
    e1:SetLabel(ac)
    e1:SetTarget(function(_e, _c) return _c:IsFaceup() and _c:IsCode(_e:GetLabel()) end)
    e1:SetValue(function(_, _re) return _re:GetOwnerPlayer()==tp end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1, tp)

    -- if they battle a "Yubel" monster, your monster is returned to the hand, at the end of the damage step
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetCondition(s.tohandcon)
    e2:SetOperation(s.tohandop)
    e2:SetLabel(ac)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2, tp)
end

function s.tohandcon(e,tp,eg,ep,ev,re,r,rp)
    local bc=Duel.GetAttacker()
    local ac=Duel.GetAttackTarget()

    if ac and bc and ((ac:IsCode(e:GetLabel()) and bc:IsSetCard(SET_YUBEL)) or (bc:IsCode(e:GetLabel()) and ac:IsSetCard(SET_YUBEL))) then
        return true
    end
    return false
end

function s.tohandop(e,tp,eg,ep,ev,re,r,rp)
    local bc=Duel.GetAttacker()
    local ac=Duel.GetAttackTarget()

    local tc=nil
    if ac:IsCode(e:GetLabel()) then
        tc=bc
    else
        tc=ac
    end

    if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
        Duel.SendtoHand(tc, nil, REASON_RULE)
    end
end