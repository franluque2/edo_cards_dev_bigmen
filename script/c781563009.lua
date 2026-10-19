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

        s.used_this_skillfirst = {}
		s.used_this_skillfirst[0] = false
		s.used_this_skillfirst[1] = false
		aux.AddValuesReset(function()
			s.used_this_skill[0] = false
			s.used_this_skill[1] = false

            s.used_this_skill_1[0] = false
            s.used_this_skill_1[1] = false

            s.used_this_skillfirst[0] = false
            s.used_this_skillfirst[1] = false
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

local FUSION_BATTLE_TECHNIQUES={76647978,44886582,1845204,10218411,55421040,61070601,24094653}

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

    s.filltables()

    --The first time each turn a Warrior monster(s) you control would be destroyed by the effect of a monster without a level, it is not destroyed.

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(_,c) return c:IsRace(RACE_WARRIOR) and c:IsFaceup() end)
	e1:SetValue(s.indval)
    Duel.RegisterEffect(e1, tp)

    --All monsters in your possession are also treated as EARTH
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_ADD_ATTRIBUTE)
    e2:SetTargetRange(LOCATION_ALL,0)
    e2:SetValue(ATTRIBUTE_EARTH)
    Duel.RegisterEffect(e2, tp)

    --rewrite fusions
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetCondition(s.rewritecon)
    e3:SetOperation(s.rewriteop)
    Duel.RegisterEffect(e3, tp)

                local e2a=Effect.CreateEffect(c)
        e2a:SetDescription(aux.Stringid(id,5))
        e2a:SetType(EFFECT_TYPE_QUICK_O)
        e2a:SetCode(EVENT_FREE_CHAIN)
        e2a:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e2a:SetRange(LOCATION_MZONE)
        e2a:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
        e2a:SetCountLimit(1)
        	e2a:SetCost(s.discost)

        e2a:SetCondition(s.condition)
        e2a:SetTarget(s.destg)
        e2a:SetOperation(s.desop)


    	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2b:SetTargetRange(LOCATION_MZONE,0)
	e2b:SetTarget(function(e,c) return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_FUSION) and c:IsLevelAbove(10) end)
	e2b:SetLabelObject(e2a)
	Duel.RegisterEffect(e2b,tp)

end


function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local tn=Duel.GetTurnPlayer()
    return tn~=tp and Duel.IsMainPhase()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local thisc=e:GetHandler()
    if not thisc:IsPosition(POS_FACEUP_ATTACK) then return end
    if tc:IsRelateToEffect(e) then
        Duel.CalculateDamage(e:GetHandler(), tc)
    end
end


function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end

function s.indval(e,re,r,rp)
	if ((r&REASON_EFFECT)~=0) and not re:GetHandler():HasLevel() then
		return 1
	else return 0 end
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

function s.revealwarriorfilter(c)
    return c:IsRace(RACE_WARRIOR) and not c:IsPublic()
end

function s.polyaddfilter(c)
    return c:IsSetCard(SET_FUSION) and c:IsAbleToHand()
end

function s.fubigfusionfilter(c)
    return c:IsFaceup() and c:IsCode(96220350,32615065)
end

function s.isfromextradeckfilter(c)
    return c:IsSummonLocation(LOCATION_EXTRA)
end

function s.sendwarriorfilter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsAbleToGrave()
end


function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    local b1=(not s.used_this_skill[e:GetHandlerPlayer()]) and Duel.IsExistingMatchingCard(s.revealwarriorfilter, tp, LOCATION_HAND, 0, 1, nil)
    local b2=(not s.used_this_skill_1[e:GetHandlerPlayer()]) and Duel.IsExistingMatchingCard(s.fubigfusionfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0) and Duel.CheckLPCost(tp, 1000)
    return aux.CanActivateSkill(e:GetHandlerPlayer()) and (b1 or b2)
end

function s.addwarriorfilter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5) and c:IsAbleToHand()
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    local b1=(not s.used_this_skill[e:GetHandlerPlayer()]) and Duel.IsExistingMatchingCard(s.revealwarriorfilter, tp, LOCATION_HAND, 0, 1, nil)
    local b2=(not s.used_this_skill_1[e:GetHandlerPlayer()]) and Duel.IsExistingMatchingCard(s.fubigfusionfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and (Duel.GetLocationCount(tp, LOCATION_MZONE) > 0) and Duel.CheckLPCost(tp, 1000)
    if not (b1 or b2) then return end
    local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,2)},
									{b2,aux.Stringid(id,3)})
    Duel.Hint(HINT_CARD,tp,id)
    if op==1 then
        s.used_this_skill[e:GetHandlerPlayer()] = true
        --reveal 1 Warrior monster in your hand, add 1 of your Fusion Battle Techniques from Outside the Duel to your hand, then, if your opponent controls a monster that was Special Summoned from the Extra Deck and this is the first time this effect resolved this turn, you can add 1 Level 5 or higher Warrior from your Deck to your hand. You can apply this effect multiple times per turn by discarding the revealed monster.
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
        local g=Duel.SelectMatchingCard(tp, s.revealwarriorfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
        if #g>0 then
            Duel.ConfirmCards(1-tp, g)
            local code=Duel.SelectCardsFromCodes(tp,1,1,nil,false,table.unpack(FUSION_BATTLE_TECHNIQUES))
            if code then
                local token=Duel.CreateToken(tp, code)
                Duel.SendtoHand(token, nil, REASON_EFFECT)
                Duel.ConfirmCards(1-tp, token)
            end
            if Duel.IsExistingMatchingCard(s.isfromextradeckfilter, tp, 0, LOCATION_MZONE, 1, nil) and not s.used_this_skillfirst[e:GetHandlerPlayer()] then
                s.used_this_skillfirst[e:GetHandlerPlayer()] = true

                if Duel.IsExistingMatchingCard(s.addwarriorfilter, tp, LOCATION_DECK, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
                    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
                    local g3=Duel.SelectMatchingCard(tp, s.addwarriorfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
                    if #g3>0 then
                        Duel.SendtoHand(g3, nil, REASON_EFFECT)
                        Duel.ConfirmCards(1-tp, g3)
                    end
                end
            end

            if g:GetFirst():IsDiscardable() and Duel.SelectYesNo(tp, aux.Stringid(id,4)) then
                Duel.SendtoGrave(g, REASON_DISCARD)
                s.used_this_skill[e:GetHandlerPlayer()] = false
            end
        end
    elseif op==2 then
        s.used_this_skill_1[e:GetHandlerPlayer()] = true
        -- Once per turn, if you control "Idaten the Conqueror Star" or "Shura the Combat Star", you can pay 1000LP and send up to 2 Warrior monsters from your Deck to the GY; Special Summon 1 "Raijin the Breakbolt Star" or "Fujin the Breakstorm Star" from Outside the Duel (This is treated as a Fusion Summon) but they cannot be used as Fusion Material, also, any battle damage they deal is halved. 
        Duel.PayLPCost(tp, 1000)
        if Duel.IsExistingMatchingCard(s.sendwarriorfilter, tp, LOCATION_DECK, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
            local g=Duel.SelectMatchingCard(tp, s.sendwarriorfilter, tp, LOCATION_DECK, 0, 1, 2, nil)
            if #g>0 then
                Duel.SendtoGrave(g, REASON_EFFECT)
            end
        end
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

function s.rewritefusionfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(10) and c:GetFlagEffect(id)==0
end

function s.rewritecon(e)
    return Duel.IsExistingMatchingCard(s.rewritefusionfilter, e:GetHandlerPlayer(), LOCATION_ALL, 0, 1, nil)
end

function s.rewriteop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rewritefusionfilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0, 0, 1)
	    Fusion.AddProcMixN(tc,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR),2)
    end
end