--Breath of the Terror Tiger
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

        aux.GlobalCheck(s, function()
        s.used_this_skill_1 = {}
        s.used_this_skill_1[0] = false
        s.used_this_skill_1[1] = false

        s.used_this_skill_2 = {}
        s.used_this_skill_2[0] = false
        s.used_this_skill_2[1] = false

        s.added_cards={}
        s.added_cards[0] = {}
        s.added_cards[1] = {}

        aux.AddValuesReset(function()
			s.used_this_skill_1[0] = false
			s.used_this_skill_1[1] = false
			s.used_this_skill_2[0] = false
			s.used_this_skill_2[1] = false
		end)
    end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, s.flipconactive, s.flipopactive, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local NORMAL_MUSIC_PRINCESSES={160208027,160004005,160004004,160203034,160208031}
local DANCES={160203036,160203037,160208033,160203038,160208034,160208035}

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    BRush.addrules()(e,tp,eg,ep,ev,re,r,rp)

    s.placecards(e,tp,eg,ep,ev,re,r,rp)

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetTarget(function(_,_c) return _c:IsOriginalCode(160208033) end)
    e1:SetTargetRange(LOCATION_ALL,0)
    e1:SetValue(CARD_FUSION)
    Duel.RegisterEffect(e1, tp)
end

function s.placecards(e,tp,eg,ep,ev,re,r,rp)
    for _, card_id in ipairs(NORMAL_MUSIC_PRINCESSES) do
        local token = Duel.CreateToken(tp, card_id)
        Duel.SendtoGrave(token, REASON_RULE)
    end
end

function s.highwindprincessfilter(c)
    return c:IsFaceup() and ((c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelAbove(7)) or (c:IsType(TYPE_FUSION)))
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    local b1= not s.used_this_skill_1[e:GetHandlerPlayer()]
    local b2= not s.used_this_skill_2[e:GetHandlerPlayer()] and 
    Duel.IsExistingMatchingCard(s.highwindprincessfilter, tp, LOCATION_MZONE, 0, 1, nil)
    return (b1 or b2) and aux.CanActivateSkill(tp)
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    local b1= not s.used_this_skill_1[e:GetHandlerPlayer()]
    local b2= not s.used_this_skill_2[e:GetHandlerPlayer()] and 
    Duel.IsExistingMatchingCard(s.highwindprincessfilter, tp, LOCATION_MZONE, 0, 1, nil)
    local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
									{b2,aux.Stringid(id,2)})

    Duel.Hint(HINT_CARD,tp,id)
    
    if op==1 then
        local num=1
        if Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_MZONE, 1, nil) then
            num=2
        end
        local g=Group.CreateGroup()
        local codes={Duel.SelectCardsFromCodes(tp,1,num,nil,false,table.unpack(NORMAL_MUSIC_PRINCESSES))}
        for _, code in ipairs(codes) do
            local token = Duel.CreateToken(tp, code)
            Duel.SendtoHand(token, nil, REASON_RULE)
            g:AddCard(token)
        end
        local fusion=Duel.CreateToken(tp,CARD_FUSION)
        Duel.SendtoHand(fusion, nil, REASON_RULE)
        g:AddCard(fusion)

        Duel.ConfirmCards(1-tp, g)

        s.used_this_skill_1[e:GetHandlerPlayer()] = true

    elseif op==2 then

        local codes={Duel.SelectCardsFromCodes(tp,1,1,nil,false,table.unpack(DANCES))}
        local g=Group.CreateGroup()
        for _, code in ipairs(codes) do
            local token = Duel.CreateToken(tp, code)
            Duel.SendtoHand(token, nil, REASON_RULE)
            g:AddCard(token)
        end
        Duel.ConfirmCards(1-tp, g)
        s.used_this_skill_2[e:GetHandlerPlayer()] = true


    end
end