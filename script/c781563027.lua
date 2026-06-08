--Reaping at High Noon
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	
        aux.GlobalCheck(s, function()
        s.used_this_skill = {}
        s.used_this_skill[0] = false
        s.used_this_skill[1] = false
    end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_DRAW)
    e1:SetCountLimit(1)
    e1:SetCondition(s.discardhandcon)
    e1:SetOperation(s.discardhandop)
    Duel.RegisterEffect(e1,tp)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetCountLimit(1)
    e2:SetCondition(s.drawfaceoffcon)
    e2:SetOperation(s.drawfaceop)
    Duel.RegisterEffect(e2,tp)

end

function s.discardhandcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and not s.used_this_skill[tp]
end

function s.togravemonfilter(c)
    return c:IsSetCard(SET_INFERNITY) and c:IsAbleToGrave() and c:IsMonster()
end

function s.tohandspelltrapfilter(c)
    return c:IsSetCard(SET_INFERNITY) and c:IsSpellTrap() and c:IsAbleToHand()
end

function s.discardhandop(e,tp,eg,ep,ev,re,r,rp)
    s.used_this_skill[tp] = true
    local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_HAND, 0, nil, REASON_RULE)
    if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.SendtoGrave(g, REASON_RULE)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
        local tc=Duel.SelectMatchingCard(tp, s.togravemonfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #tc>0 then
            Duel.SendtoGrave(tc, REASON_RULE)
        end
        local g2=Duel.GetMatchingGroup(s.tohandspelltrapfilter, tp, LOCATION_DECK, 0, nil)
        if #g2>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local tc2=g2:Select(tp, 1, 1, nil)
            Duel.SendtoHand(tc2, nil, REASON_RULE)
            Duel.ConfirmCards(1-tp, tc2)
        end

        if Duel.GetTurnCount()>1  and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            local token1=Duel.CreateToken(tp, 79759861)
            local token2=Duel.CreateToken(tp, 810000018)
            local g3=Group.FromCards(token1,token2)
            Duel.SendtoHand(g3, nil, REASON_RULE)
            Duel.ConfirmCards(1-tp, g3)
        end
    end
end

function s.spsummonopfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, true, false, POS_FACEUP) and (c:GetTextAttack()>=0) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0
end

function s.spsummonplayerfilter(c,e,tp)
    return c:IsSetCard(SET_INFERNITY) and s.spsummonopfilter(c,e,tp)
end

function s.drawfaceoffcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0 and (Duel.GetTurnCount()>1 or Duel.IsDuelType(DUEL_1ST_TURN_DRAW))
        and Duel.IsExistingMatchingCard(s.spsummonplayerfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp)

end

function s.fuinfernitysynchromonster(c)
    return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_INFERNITY) and c:IsType(TYPE_SYNCHRO)
end

function s.canbespecialedcard(c,e)
    return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, c:GetControler(), true, false, POS_FACEUP)
end

function s.drawfaceop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE|PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)


        Duel.Hint(HINT_CARD, tp, id)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g1=Duel.SelectMatchingCard(tp, s.spsummonopfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
        local g2=nil
        if Duel.IsExistingMatchingCard(s.spsummonopfilter, 1-tp, LOCATION_DECK, 0, 1, nil, e, 1-tp) then
            Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_SPSUMMON)
            g2=Duel.SelectMatchingCard(1-tp, s.spsummonopfilter, 1-tp, LOCATION_DECK, 0, 1, 1, nil, e, 1-tp)
        end

        local canchoose=(not g2) or (g1:GetFirst():GetTextAttack()==g2:GetFirst():GetTextAttack())
        or Duel.IsExistingMatchingCard(s.fuinfernitysynchromonster, tp, LOCATION_MZONE, 0, 1, nil)

        if canchoose then
            if not g2 then
                if g1 then
                    if g1:GetFirst():IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, true, false, POS_FACEUP) and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
                        Duel.SpecialSummon(g1, SUMMON_TYPE_SPECIAL, tp, tp, true, false, POS_FACEUP)
                    else
                        Duel.SendtoGrave(g1, REASON_RULE)
                    end
                end
            else
                local combinedg=Group.FromCards(g1:GetFirst(), g2:GetFirst())
                Duel.ConfirmCards(1-tp, g1)
                Duel.ConfirmCards(tp, g2)
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
                local sg=combinedg:FilterSelect(tp, s.canbespecialedcard, 1, 1, nil, e)
                local tc=sg:GetFirst()
                Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tc:GetControler(), tc:GetControler(), true, false, POS_FACEUP)
                combinedg:RemoveCard(tc)
                if #combinedg>0 then
                    Duel.SendtoGrave(combinedg, REASON_RULE)
                end
                
            end
        else
            local combinedg=Group.FromCards(g1:GetFirst(), g2:GetFirst())
		Duel.ConfirmCards(1-tp, g1)
		Duel.ConfirmCards(tp, g2)

            local higheratk=g1:GetFirst():GetTextAttack()>g2:GetFirst():GetTextAttack() and g1 or g2
            if higheratk~=nil then
                Duel.SpecialSummon(higheratk, SUMMON_TYPE_SPECIAL, higheratk:GetFirst():GetControler(), higheratk:GetFirst():GetControler(), true, false, POS_FACEUP)
                combinedg:RemoveCard(higheratk:GetFirst())
                if #combinedg>0 then
                    Duel.SendtoGrave(combinedg, REASON_RULE)
                end

            end

        end
    end
end