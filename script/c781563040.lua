--Grand Lord of the Barians
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

     local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_STARTUP)
    e3:SetRange(0x5f)
    e3:SetCountLimit(1)
    e3:SetOperation(s.shuffledownop)
    c:RegisterEffect(e3)

        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

function s.cardfilter(c, tp)
    return (not c:IsTrap())
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
    if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
    if #g > 0 then
        local startinghandnum=Duel.GetStartingHand(tp)+1
        local g2=g:RandomSelect(tp, startinghandnum)

        Duel.MoveToDeckTop(g2)
    end
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end
function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()
    s.placecards(e,tp,eg,ep,ev,re,r,rp)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1, tp)

    s.buffopponent(e,tp,eg,ep,ev,re,r,rp)

    --During your Draw Phase, before you draw, you may give up your Normal Draw for the turn to add 1 "Numeron" Spell from your GY to your hand.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetCondition(s.repdrawcon)
    e2:SetOperation(s.repdrawop)
    Duel.RegisterEffect(e2, tp)
end

function s.numeronaddfilter(c)
    return c:IsSetCard(SET_NUMERON) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function s.repdrawcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
        and Duel.GetDrawCount(tp)>0 and Duel.IsExistingMatchingCard(s.numeronaddfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.repdrawop(e,tp,eg,ep,ev,re,r,rp)
    local dt=Duel.GetDrawCount(tp)
    if dt~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_CARD,tp,id)
        local _replace_count=0
        local _replace_max=dt
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_DRAW_COUNT)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_DRAW)
        e1:SetValue(0)
        Duel.RegisterEffect(e1,tp)

        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.numeronaddfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

function s.buffopponent(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    Duel.SetLP(1-tp, 100000)
    if Duel.SelectYesNo(1-tp, aux.Stringid(id, 1)) then
       local astralforcetoken=Duel.CreateToken(1-tp,45950291)
       Duel.SendtoGrave(astralforcetoken, REASON_RULE)
    end

end

function s.placecards(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --place 1 "Numeron Network" from Outside the Duel face-up in your Field Zone, then if you're going first, end your turn.
    local nnetwork=Duel.CreateToken(tp, CARD_NUMERON_NETWORK)
    Duel.MoveToField(nnetwork, tp, tp, LOCATION_FZONE, POS_FACEUP, true)

    -- It gains the following effects while it is face-up on the field
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(id)
    e1:SetTargetRange(1,0)
    --e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetRange(LOCATION_FZONE)
    nnetwork:RegisterEffect(e1)

    --While your opponent does not hold a "Rank-Up-Magic" card in their hand, this card cannot be targeted by card effects. Also they cannot destroy it by card effects.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(function(e) return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),0,LOCATION_HAND,1,nil,SET_RANK_UP_MAGIC) end)
    e2:SetValue(aux.tgoval)
    --e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    nnetwork:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(aux.indoval)
    nnetwork:RegisterEffect(e3)
    nnetwork:RegisterFlagEffect(id, 0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))

    if Duel.IsTurnPlayer(tp) and Duel.GetTurnCount()==1 then
        local eskip=Effect.CreateEffect(e:GetHandler())
		eskip:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		eskip:SetType(EFFECT_TYPE_FIELD)
		eskip:SetCode(EFFECT_CANNOT_BP)
		eskip:SetTargetRange(1,0)
		eskip:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(eskip,tp)

        Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_END,RESET_PHASE+PHASE_END,1)
    end
end

function s.countertraprewritefilter(c)
    return c:IsType(TYPE_COUNTER) and c:IsTrap() and c:GetFlagEffect(id)==0
end

function s.numeronchaosritualrewritefilter(c)
    return c:IsCode(41850466) and c:GetFlagEffect(id)==0
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return (Duel.GetMatchingGroupCount(s.countertraprewritefilter,tp,LOCATION_ALL,0,nil)>0)
    or (Duel.GetMatchingGroupCount(s.numeronchaosritualrewritefilter,tp,LOCATION_ALL,0,nil)>0)
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.countertraprewritefilter,tp,LOCATION_ALL,0,nil)
    for tc in g1:Iter() do

        tc:RegisterFlagEffect(id,0,0,1)

        local effs={tc:GetOwnEffects()}
        for _,eff in ipairs(effs) do
            if eff:IsHasType(EFFECT_TYPE_ACTIVATE) then
                local oldcon=eff:GetCondition()
                if not oldcon then oldcon=function() return true end end
                local eff2=eff:Clone()
                eff2:SetRange(LOCATION_DECK)
                eff2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
                    
                    return oldcon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetTurnPlayer()~=tp and e:GetHandler():GetSequence() >= (Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) - (5))
                        and Duel.IsPlayerAffectedByEffect(tp, id) and Duel.GetFieldGroupCount(tp, LOCATION_ONFIELD, 0) <= 1
                end)
                eff2:SetCost(aux.TRUE)
                tc:RegisterEffect(eff2)
            end
        end
    end

    local g2=Duel.GetMatchingGroup(s.numeronchaosritualrewritefilter,tp,LOCATION_ALL,0,nil)
    for tc in g2:Iter() do
            tc:RegisterFlagEffect(id,0,0,1)

        local effs={tc:GetOwnEffects()}
        for _,eff in ipairs(effs) do
            if eff:IsHasType(EFFECT_TYPE_ACTIVATE) then
                eff:SetCondition(aux.TRUE)
                eff:SetTarget(s.newchaosrittargetfunction)
            end
        end

    end
end


function s.spfilter(c,e,tp)
	return c:IsCode(89477759) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.matfilter(c)
	return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ)
end
function s.rmgchk(f,id)
	return function(c)
		return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and f(c,id)
	end
end

function s.newchaosrittargetfunction(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.rmgchk(Card.IsCode,CARD_NUMERON_NETWORK),tp,LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(s.rmgchk(s.matfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_ONFIELD,0,4,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local atg1=Duel.SelectTarget(tp,s.rmgchk(Card.IsCode,CARD_NUMERON_NETWORK),tp,LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_ONFIELD,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local atg2=Duel.SelectTarget(tp,s.rmgchk(s.matfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_ONFIELD,0,4,4,nil)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	atg1:Merge(atg2)
	local lvgg=atg1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,tp,LOCATION_EXTRA)
	if #lvgg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,lvgg,#lvgg,0,0)
	end
end