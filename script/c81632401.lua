--Ultimate Ritual of the Forbidden Lord (CT)
local s, id = GetID()
function s.initial_effect(c)
    --Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.activate2)
    c:RegisterEffect(e2)

    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_LEAVE_GRAVE+CATEGORY_DRAW)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetType(EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetTarget(s.shuffletarget)
    e3:SetCost(aux.bfgcost)
    e3:SetOperation(s.shuffleop)
    c:RegisterEffect(e3)
end

function s.exodfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0xde) or c:IsCode(13893596))
end


function s.shuffletarget(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter2(chkc) and eg:IsContains(chkc) end
    if chk == 0 then return Duel.IsExistingMatchingCard(s.exodfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and Duel.IsPlayerCanDraw(tp) and eg:IsExists(s.filter2, 1, nil) end

    local tg=eg:Filter(s.filter2, nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=tg:Select(tp, 1, 99)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,#g)
end

function s.shuffleop(e, tp, eg, ep, ev, re, r, rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)==0 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,#ct,REASON_EFFECT)
	end
end


function s.filter2(c)
    return (c:IsSetCard(SET_FORBIDDEN_ONE)) and c:IsAbleToDeck()
end

function s.sumfilter(c, e, tp)
    return (c:IsSetCard(0xde) or c:IsCode(13893596)) and c:IsMonster() and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, true, true)
end

function s.sendfilter(c)
    return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsMonster() and c:IsAbleToGrave()
end

function s.target2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.filter2, tp, LOCATION_GRAVE, 0, 1, nil) and
        Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp) end
end

function s.winfilter(c, rc)
    return c:IsRelateToCard(rc) and c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsMonster()
end

function s.activate2(e, tp, eg, ep, ev, re, r, rp)
    local toshuffle = Duel.GetMatchingGroup(s.filter2, tp, LOCATION_GRAVE, 0, nil)
    if Duel.SendtoDeck(toshuffle, tp, SEQ_DECKSHUFFLE, REASON_EFFECT) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
        if #g > 0 then
            Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)

            local g2 = Duel.GetMatchingGroup(s.sendfilter, tp, LOCATION_DECK, 0, nil)
            if g2:GetClassCount(Card.GetCode) >= 2 then
                local cg = Group.CreateGroup()
                for i = 1, 2 do
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
                    local sg = g2:Select(tp, 1, 1, nil)
                    g2:Remove(Card.IsCode, nil, sg:GetFirst():GetCode())
                    cg:Merge(sg)
                end
                Duel.SendtoGrave(cg, REASON_EFFECT)

                local exd = g:GetFirst()
                if exd:IsCode(13893596) then
                    local tc = cg:GetFirst()
                    while tc do
                        tc:SetReasonCard(exd)
                        tc = cg:GetNext()
                    end

                    local g3 = Duel.GetMatchingGroup(s.winfilter, tp, LOCATION_GRAVE, 0, nil, exd)
                    if g3:GetClassCount(Card.GetCode) == 5 then
                        Duel.Win(tp, WIN_REASON_EXODIUS)
                    end
                end
            end
        end
    end
end

function s.filter(c)
    return c:IsLevelAbove(4) and c:IsMonster() and (c:IsSetCard(0xde) or c:IsCode(13893596)) and c:IsAbleToHand()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
