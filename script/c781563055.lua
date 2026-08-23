--A Carnival lit by Numbers
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	
                local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)

    aux.GlobalCheck(s, function()
        s.forcingluckresults = {}
        s.forcingluckresults[0] = false
        s.forcingluckresults[1] = false

        s.shouldforceluckresults = {}
        s.shouldforceluckresults[0] = false
        s.shouldforceluckresults[1] = false

        s.important_card_id=nil

        s.last_die_results = {}
        s.altered_dice_results = false

        aux.AddValuesReset(function()
			s.forcingluckresults[0] = s.shouldforceluckresults[0]
            s.forcingluckresults[1] = s.shouldforceluckresults[1]
		end)


    end)
end

function s.shouldberewritingluckresults(tp)
    return s.forcingluckresults[tp] and Duel.IsExistingMatchingCard(aux.FilterFaceup, tp, LOCATION_ONFIELD, 0, 1, nil, Card.IsCode, 82308875)
end


--Duel.TossDice
--Rolls (int count1) dice on behalf of (int player) and (int count2) dice on behalf of the opponent of (int player). Returns all the results of the rolls.
local oldfunc=Duel.TossDice
function Duel.TossDice(tp,dp,dop)
    local forcetp = s.shouldberewritingluckresults(tp) and dp and dp>0
    local forceop = s.shouldberewritingluckresults(1-tp) and dop and dop>0
    if not forcetp and not forceop then
        s.altered_dice_results = false
        return oldfunc(tp,dp,dop)
    end

    local rolledadice = false

    local forcedvalue =  6
    local results = {}
    if s.important_card_id then
        if s.important_card_id == 82308875 then -- Lucky Straight
            results = {6, 1}
            dp = dp and dp - 2 or 0
        end
        if s.important_card_id == 42421606 then -- Crazy Box
            forcedvalue = Duel.GetRandomNumber(2,5)
        end
    end

    if forcetp then
        for i=1,dp do
            results[#results+1] = forcedvalue
        end
    elseif dp and dp>0 then
        local realresults = {oldfunc(tp,dp)}
        for i=1,#realresults do
            results[#results+1] = realresults[i]
        end
    end

    if forceop then
        for i=1,dop do
            results[#results+1] = forcedvalue
        end
    elseif dop and dop>0 then
        local realresults = {oldfunc(1-tp,dop)}
        for i=1,#realresults do
            results[#results+1] = realresults[i]
        end
    end

    s.altered_dice_results = true
    s.last_die_results = results
    if not rolledadice then
        Duel.TossDice(tp,0,0)
    end
    return table.unpack(results)
end

--Duel.GetDiceResult
--Returns the values corresponding to the results of the last dice rolls.
local oldfuncresult=Duel.GetDiceResult
function Duel.GetDiceResult()
    local results = oldfuncresult()
    if s.altered_dice_results then
        return s.last_die_results
    end
    s.last_die_results = results
    return results
end

local oldfuncdraw = Duel.Draw
Duel.Draw = function(tp, num, reason)
	if s.shouldberewritingluckresults(tp) then
		s.shuffletotopop(nil, tp)
	end
	return oldfuncdraw(tp, num, reason)
end

function s.cardfilter(c, tp)
    return (c.roll_dice or c:IsSetCard(SET_RAISE_MOON)) and c:IsMonster()
end

function s.shuffletotopop(e, tp, eg, ep, ev, re, r, rp)
    if not s.shouldberewritingluckresults(tp) then return end
    local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
	if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
    local topcard=Duel.GetDecktopGroup(tp, 1)
    if topcard and s.cardfilter(topcard:GetFirst(), tp) then
        return
    end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	if #g > 0 then
		Duel.MoveToDeckTop(g:GetFirst())
	end
end


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
	local c = e:GetHandler()

    s.forcingluckresults[tp]=true
    s.shouldforceluckresults[tp]=true

    local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetOperation(s.shuffletotopop)
	e1:SetCountLimit(1)
	Duel.RegisterEffect(e1, tp)

    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.negskillcon)
    e2:SetOperation(s.negskillop)
    Duel.RegisterEffect(e2, tp)


    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetCondition(s.rewritexyzscon)
    e3:SetOperation(s.rewritexyzsop)
    Duel.RegisterEffect(e3, tp)


    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAIN_SOLVING)
    e4:SetOperation(s.logcardop)
    Duel.RegisterEffect(e4, tp)

    -- Xyz Monsters in your Possession are treated as LIGHT "Raise Moon" Rank 7 Monsters
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e5:SetTargetRange(LOCATION_ALL, 0)
    e5:SetTarget(function(e, c) return c:IsType(TYPE_XYZ) end)
    e5:SetValue(ATTRIBUTE_LIGHT)
    Duel.RegisterEffect(e5, tp)

    local e6 = e5:Clone()
    e6:SetCode(EFFECT_CHANGE_RANK)
    e6:SetValue(7)
    Duel.RegisterEffect(e6, tp)

    local e7 = e5:Clone()
    e7:SetCode(EFFECT_ADD_SETCODE)
    e7:SetValue(SET_RAISE_MOON)
    Duel.RegisterEffect(e7, tp)

    -- Xyz Monsters and "Raise Moon" monsters you control cannot attack directly the turn they are summoned
  	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(s.limtg)
    Duel.RegisterEffect(e8, tp)


    --Level 3 or lower monsters in your Hand and Field gain the following effects:
    --When you draw this card: You can reveal it; Special Summon it.

    local e01=Effect.CreateEffect(c)
	e01:SetDescription(aux.Stringid(id,2))
	e01:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e01:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e01:SetCode(EVENT_DRAW)
	e01:SetCost(Cost.SelfReveal)
	e01:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,1,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	end)
	e01:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
		end
	end)

    local egrant1 = Effect.CreateEffect(c)
    egrant1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    egrant1:SetTargetRange(LOCATION_HAND + LOCATION_MZONE + LOCATION_DECK, 0)
    egrant1:SetTarget(function(e, c) return c:IsLevelBelow(3) and c:IsMonster() end)
    egrant1:SetLabelObject(e01)
    Duel.RegisterEffect(egrant1, tp)

    --If this card is Normal or Special Summoned from the Hand: You can draw 1 card.
   	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,3))
	e3a:SetCategory(CATEGORY_DRAW)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsSummonLocation(LOCATION_HAND)
	end)
	e3a:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end)
	e3a:SetOperation(s.drop)
    local e3b=e3a:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)

    local egrant2 = egrant1:Clone()
    egrant2:SetLabelObject(e3a)
    Duel.RegisterEffect(egrant2, tp)

    local egrant3 = egrant1:Clone()
    egrant3:SetLabelObject(e3b)
    Duel.RegisterEffect(egrant3, tp)

end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end

function s.limtg(e,c)
    return (c:IsType(TYPE_XYZ) or c:IsSetCard(SET_RAISE_MOON)) and (c:IsStatus(STATUS_SUMMON_TURN) or c:IsStatus(STATUS_SPSUMMON_TURN) or c:IsStatus(STATUS_FLIP_SUMMON_TURN))
end

function s.negskillcon(e, tp, eg, ep, ev, re, r, rp)
    return s.shouldforceluckresults[tp] and s.shouldberewritingluckresults(tp) and eg:IsExists(Card.IsType, 1, nil, TYPE_CONTINUOUS)
end

function s.negskillop(e, tp, eg, ep, ev, re, r, rp)
    s.forcingluckresults[tp] = false
    Duel.Hint(HINT_CARD, tp, id)
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetTargetRange(1,0)
    e3:SetCode(id)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)

end

function s.xyztorewritefilter(c)
    return c:IsType(TYPE_XYZ) and c:GetFlagEffect(id)==0
end

function s.rewritexyzscon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.xyztorewritefilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritexyzsop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.xyztorewritefilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 1)

        if tc:IsSetCard(SET_NUMBER) then
            local effs = {tc:GetOwnEffects()}
            for _, eff in ipairs(effs) do
                if eff:IsHasType(EFFECT_TYPE_IGNITION) then
                    local neweff=eff:Clone()
                    neweff:SetType(EFFECT_TYPE_QUICK_O)
                    neweff:SetCode(EVENT_FREE_CHAIN)
                    neweff:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
                        return Duel.IsMainPhase() and (Duel.GetTurnPlayer() ~= tp) and (Duel.GetFlagEffect(tp, id)>0)
                    end)
                    local oldcost=eff:GetCost()
                    if oldcost then
                        neweff:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
                            if chk==0 then return oldcost(e, tp, eg, ep, ev, re, r, rp, 0) and Duel.CheckLPCost(tp, 700) end
                            Duel.PayLPCost(tp, 700)
                            s.forcingluckresults[tp] = false
                                local e3=Effect.CreateEffect(e:GetHandler())
                                e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
                                e3:SetDescription(aux.Stringid(id,0))
                                e3:SetTargetRange(1,0)
                                e3:SetCode(id)
                                e3:SetReset(RESET_PHASE+PHASE_END)
                                Duel.RegisterEffect(e3,tp)

                            return oldcost(e, tp, eg, ep, ev, re, r, rp, 1)
                        end)
                    else
                        neweff:SetCost(function(e, tp, eg, ep, ev, re, r, rp, chk)
                            if chk==0 then return Duel.CheckLPCost(tp, 700) end
                            s.forcingluckresults[tp] = false

                                local e3=Effect.CreateEffect(e:GetHandler())
                                e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
                                e3:SetDescription(aux.Stringid(id,0))
                                e3:SetTargetRange(1,0)
                                e3:SetCode(id)
                                e3:SetReset(RESET_PHASE+PHASE_END)
                                Duel.RegisterEffect(e3,tp)

                            Duel.PayLPCost(tp, 700)
                        end)
                    end
                    neweff:SetHintTiming(0, TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
                    tc:RegisterEffect(neweff)
                end
            end
        end

        Xyz.AddProcedure(tc,s.matfilter,nil,2,nil,nil,nil,nil,false)
    end
end

function s.matfilter(c,xyz,sumtype,tp)
	return c:IsLevel(7) or (c:HasLevel() and c.roll_dice)
end

function s.logcardop(e, tp, eg, ep, ev, re, r, rp)
    local rc=re:GetHandler()
    if rc.roll_dice then
        s.important_card_id=rc:GetOriginalCode()
    else
        s.important_card_id=nil
    end
end