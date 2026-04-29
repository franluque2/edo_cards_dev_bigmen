--Conqueror of Stars
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	aux.GlobalCheck(s, function()
		s.used_this_skill = {}
		s.used_this_skill[0] = false
		s.used_this_skill[1] = false

        s.used_this_skill_1 = {}
		s.used_this_skill_1[0] = false
		s.used_this_skill_1[1] = false
		aux.AddValuesReset(function()
			s.used_this_skill[0] = false
			s.used_this_skill[1] = false

            s.used_this_skill_1[0] = false
            s.used_this_skill_1[1] = false
		end)
	end)


	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		s.flipconactive, s.flipopactive, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)
end

local cards_to_summon={99991455,511002015}
local group_cards_to_summon={}
group_cards_to_summon[0]=Group.CreateGroup()
group_cards_to_summon[1]=Group.CreateGroup()

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

    s.filltables()
end

function s.filltables()
    if #group_cards_to_summon[0]>0 and #group_cards_to_summon[1]>0 then return end
    for p=0,1 do
            for _,code in ipairs(cards_to_summon) do
            local card=Duel.CreateToken(p, code)
            if card then
                group_cards_to_summon[p]:AddCard(card)
            end
        end
    end
end

function s.discardwarriorfilter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsDiscardable()
end

function s.polyaddfilter(c)
    return c:IsSetCard(SET_FUSION) and c:IsAbleToHand()
end

function s.fubigfusionfilter(c)
    return c:IsFaceup() and c:IsCode(96220350,32615065)
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    local b1=(not s.used_this_skill[e:GetHandlerPlayer()]) and Duel.IsExistingMatchingCard(s.discardwarriorfilter, tp, LOCATION_HAND, 0, 1, nil) and Duel.IsExistingMatchingCard(s.polyaddfilter, tp, LOCATION_DECK, 0, 1, nil)
    local b2=(not s.used_this_skill_1[e:GetHandlerPlayer()]) and Duel.IsExistingMatchingCard(s.fubigfusionfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0) and Duel.CheckLPCost(tp, 2000)
    return aux.CanActivateSkill(e:GetHandlerPlayer()) and (b1 or b2)
end

function s.addwarriorfilter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5) and c:IsAbleToHand()
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    local b1=(not s.used_this_skill[e:GetHandlerPlayer()]) and Duel.IsExistingMatchingCard(s.discardwarriorfilter, tp, LOCATION_HAND, 0, 1, nil) and Duel.IsExistingMatchingCard(s.polyaddfilter, tp, LOCATION_DECK, 0, 1, nil)
    local b2=(not s.used_this_skill_1[e:GetHandlerPlayer()]) and Duel.IsExistingMatchingCard(s.fubigfusionfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0) and Duel.CheckLPCost(tp, 2000)
    if not (b1 or b2) then return end
    local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)},
									{b2,aux.Stringid(id,3)})
    Duel.Hint(HINT_CARD,tp,id)
    if op==1 then
        s.used_this_skill[e:GetHandlerPlayer()] = true
        --Discard 1 Warrior monster, add 1 "Fusion" or "Polymerization" card from your Deck to your hand, then, if your opponent controls a monster Special Summoned from the Extra Deck,  you can add 1 Level 5 or higher Warrior monster from your Deck to your hand.
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
        local g=Duel.SelectMatchingCard(tp, s.discardwarriorfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
        if #g>0 and Duel.SendtoGrave(g, REASON_DISCARD)~=0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local g2=Duel.SelectMatchingCard(tp, s.polyaddfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
            if #g2>0 then
                Duel.SendtoHand(g2, nil, REASON_EFFECT)
                Duel.ConfirmCards(1-tp, g2)
                if Duel.IsExistingMatchingCard(Card.IsSummonLocation, tp, 0, LOCATION_MZONE, 1, nil, LOCATION_EXTRA) and Duel.IsExistingMatchingCard(s.addwarriorfilter, tp, LOCATION_DECK, 0, 1, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
                    local g3=Duel.SelectMatchingCard(tp, s.addwarriorfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
                    if #g3>0 then
                        Duel.SendtoHand(g3, nil, REASON_EFFECT)
                        Duel.ConfirmCards(1-tp, g3)
                    end
                end
            end
            Duel.ShuffleHand(tp)
        end
    elseif op==2 then
        s.used_this_skill_1[e:GetHandlerPlayer()] = true
        -- pay 2000LP; Special Summon 1 "Raijin the Breakbolt Star" or "Fujin the Breakstorm Star" from outside of the duel (This is treated as a Fusion Summon) but they cannot be used as Fusion Material, also, any damage they deal is halved
        Duel.PayLPCost(tp, 2000)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g=group_cards_to_summon[tp]:Filter(Card.IsCanBeSpecialSummoned, nil, e, SUMMON_TYPE_FUSION, tp, true, false)
        if #g>0 then
            local tc=g:Select(tp, 1, 1, nil):GetFirst()
            local token=Duel.CreateToken(tp, tc:GetOriginalCode())
            Duel.SpecialSummon(token, SUMMON_TYPE_FUSION, tp, tp, true, false, POS_FACEUP)
            Card.CompleteProcedure(token)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetDescription(aux.Stringid(id,1))
            e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            token:RegisterEffect(e1, true)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
            token:RegisterEffect(e2, true)
        end
    end
end