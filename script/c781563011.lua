--Where HEROes Began
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
	
        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)

    	aux.GlobalCheck(s, function()
		s.turncounter = {}
		s.turncounter[0] = 0
		s.turncounter[1] = 0

        s.add_activations={}
        s.add_activations[0] = false
        s.add_activations[1] = false

        s.cards_added_this_turn={}
        s.cards_added_this_turn[0] = {}
        s.cards_added_this_turn[1] = {}

        aux.AddValuesReset(function()
            s.add_activations[0] = false
            s.add_activations[1] = false

            s.cards_added_this_turn[0] = {}
            s.cards_added_this_turn[1] = {}
		end)
        end)

end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

            local e2 = Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE + PHASE_STANDBY)
        e2:SetCondition(s.flipconsb)
        e2:SetCountLimit(1)
        e2:SetOperation(s.flipopsb)
        Duel.RegisterEffect(e2, tp)

        local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PREDRAW)
    e1:SetCountLimit(1)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(tp) end)
    e1:SetOperation(s.addheroicpouch)
    Duel.RegisterEffect(e1, tp)

        local e9 = Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e9:SetCode(EVENT_TURN_END)
    e9:SetCountLimit(1)
    e9:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(tp) end)
    e9:SetOperation(s.removeheroicpouch)
    Duel.RegisterEffect(e9, tp)


    --Your opponent takes no Battle Damage from Fusion Monsters you control that do not specifically name a monster as material.
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_NO_BATTLE_DAMAGE)
    e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e6:SetTargetRange(LOCATION_MZONE,0)
    e6:SetTarget(s.efilter)
    e6:SetValue(1)
    Duel.RegisterEffect(e6, tp)

    --Each time you Fusion Summon a monster, you can add 1 "HERO" Normal monster from your Deck or GY to your hand with a different name than the cards added this way to your hand this turn
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e7:SetCode(EVENT_SPSUMMON_SUCCESS)
    e7:SetCondition(s.addheronormalcon)
    e7:SetOperation(s.addheronormalop)
    Duel.RegisterEffect(e7, tp)


end

function s.efilter(e,c)
	return c:IsType(TYPE_FUSION) and not (c.material)
end

function s.flipconsb(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentChain() == 0 and Duel.GetTurnPlayer() == tp
        and s.turncounter[tp] < 6
end

function s.flipopsb(e, tp, eg, ep, ev, re, r, rp)
    if s.turncounter[tp]>0 then
        Duel.Hint(HINT_CARD, tp, id)
    end
    if s.turncounter[tp] > 1 then
        if s.turncounter[tp] > 2 then
            if s.turncounter[tp] > 3 then
                if s.turncounter[tp] > 4 then
                    if s.turncounter[tp] == 5 then
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
        if s.turncounter[tp] == 1 then
            local gencard = Duel.CreateToken(tp, 74825788)
            Duel.SendtoHand(gencard, tp, REASON_RULE)
            Duel.ConfirmCards(1 - tp, gencard)
        end
    end

    s.turncounter[tp] = s.turncounter[tp] + 1
end

local bricks={20721928,84327329,58932615,21844576,79979666,86188410,59793705,45906428,11881272,63035430,55428811,18482473,33995387, CARD_POLYMERIZATION, 40237839}
local polyaccess={CARD_POLYMERIZATION, 40237839}

function s.cardfilter(c, tp)
    return c:IsCode(table.unpack(bricks)) and c:GetSequence() >= (Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) - (20))
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
    local oneallowed=Duel.GetFirstMatchingCard(Card.IsOriginalCode, tp, LOCATION_DECK, 0, nil, table.unpack(polyaccess))
    if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
    if #g > 0 then
        Duel.MoveToDeckBottom(g)
    end
    if oneallowed then
        Duel.MoveToDeckTop(oneallowed)
    end
end



function s.addheroicpouch(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, tp, id)

    local g = Group.CreateGroup()
    local tc = Duel.CreateToken(tp, id+1)
    tc:RegisterFlagEffect(id, 0, 0, 0, tp)
    g:AddCard(tc)

    Duel.SendtoHand(g, nil, REASON_RULE)
    Duel.ConfirmCards(1-tp, g)
end

function s.remfilter(c)
    return c:IsCode(id+1) and c:IsSpell() and c:GetFlagEffect(id) > 0
end

function s.removeheroicpouch(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.remfilter, tp, LOCATION_ALL, 0, nil)
    Duel.RemoveCards(g)
end


function s.addherofilter(c, tp)
    return c:IsSetCard(SET_HERO) and c:IsMonster() and c:IsType(TYPE_NORMAL) and (not s.cards_added_this_turn[tp][c:GetCode()]) and c:IsAbleToHand()
end



function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsFusionSummoned() and c:IsType(TYPE_FUSION)
end
function s.addheronormalcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.addherofilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil, tp)
end

function s.addfusionfilter(c)
    return c:IsSetCard(SET_FUSION) and c:IsAbleToHand()
end

function s.addheronormalop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_CARD,tp,id)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.addherofilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, 1, nil, tp)
        if #g > 0 then
            local tc = g:GetFirst()
            s.cards_added_this_turn[tp][tc:GetCode()] = true
            Duel.SendtoHand(tc, tp, REASON_EFFECT)
            Duel.ConfirmCards(1-tp, tc)

            if not s.add_activations[tp] then
                s.add_activations[tp] = true
                if Duel.IsExistingMatchingCard(s.addfusionfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
                    local fg = Duel.SelectMatchingCard(tp, s.addfusionfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, 1, nil)
                    if #fg > 0 then
                        Duel.SendtoHand(fg, tp, REASON_EFFECT)
                        Duel.ConfirmCards(1-tp, fg)
                    end
                end
            end
        end
    end
end