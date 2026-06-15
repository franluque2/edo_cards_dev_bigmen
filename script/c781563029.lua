--Deck Master - Nightmare Penguin
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
	
    aux.GlobalCheck(s, function()
        s.turned_deckmaster_on = {}
        s.turned_deckmaster_on[0] = false
        s.turned_deckmaster_on[1] = false

        s.used_this_skill_opt = {}
        s.used_this_skill_opt[0] = false
        s.used_this_skill_opt[1] = false

        
        s.used_this_skill_opt_summon = {}
        s.used_this_skill_opt_summon[0] = false
        s.used_this_skill_opt_summon[1] = false

        s.left_field_this_turn = 0
        aux.AddValuesReset(function()
			s.used_this_skill_opt[0] = false
			s.used_this_skill_opt[1] = false

            s.used_this_skill_opt_summon[0] = false
            s.used_this_skill_opt_summon[1] = false
            
            s.left_field_this_turn = 0
		end)
    end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,s.flipconactive, s.flipopactive, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end


function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    return (not s.turned_deckmaster_on[e:GetHandlerPlayer()])  and aux.CanActivateSkill(tp) --and Duel.GetFlagEffect(tp, id)>5
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    s.turned_deckmaster_on[e:GetHandlerPlayer()] = true
    Duel.Hint(HINT_CARD, tp, id)
    local c = e:GetHandler()
    Duel.Hint(HINT_SKILL_REMOVE, tp, id)
    Duel.Hint(HINT_SKILL,tp,id+1)

    Duel.ResetFlagEffect(tp, id)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    local ce=Duel.IsPlayerAffectedByEffect(tp, id)
    if ce then
        ce:Reset()
    end

    --WATER Monsters you control gain 200 ATK/DEF for each card that left the field this turn. 
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(function(_,_c) return _c:IsFaceup() and _c:IsAttribute(ATTRIBUTE_WATER) end)
    e1:SetValue(function() return s.left_field_this_turn*200 end)
    Duel.RegisterEffect(e1, tp)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    Duel.RegisterEffect(e2, tp)


     local e3 = Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1)
    e3:SetCondition(s.spsumdeckmastercon)
    e3:SetOperation(s.spsumdeckmasterop)
    Duel.RegisterEffect(e3, tp)
end

function s.spsumdeckmastercon(e, tp, eg, ep, ev, re, r, rp)
    return s.turned_deckmaster_on[e:GetHandlerPlayer()] and aux.CanActivateSkill(tp) and Duel.CheckLPCost(tp, 1000) and Duel.GetFlagEffect(tp, id)==1
        and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsPlayerCanSpecialSummonMonster(tp, id+1, SET_PENGUIN+SET_VIRTUAL_WORLD, TYPE_MONSTER+TYPE_EFFECT, 900, 1800, 4, RACE_AQUA, ATTRIBUTE_WATER)
end

function s.spsumdeckmasterop(e, tp, eg, ep, ev, re, r, rp)
    Duel.PayLPCost(tp, 1000)
    Duel.Hint(HINT_CARD, tp, id+1)
    Duel.Hint(HINT_SKILL_REMOVE, tp, id+1)
    local token=Duel.CreateToken(tp, id+1)
    Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    --return it to your Deck Master Zone if it would leave the field.

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetOperation(s.rmval)
    token:RegisterEffect(e1)

end

function s.rmval(e)
    Duel.ResetFlagEffect(e:GetHandler():GetOwner(), id)
    Duel.RegisterFlagEffect(e:GetHandler():GetOwner(), id, 0, 0, 0)
    Duel.Hint(HINT_SKILL, e:GetHandler():GetOwner(), id+1)
    Duel.SendtoDeck(e:GetHandler(),nil,-2,REASON_RULE)
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()


    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e3:SetDescription(aux.Stringid(id+1,3))
    e3:SetCode(id)
    e3:SetTargetRange(1,0)
    Duel.RegisterEffect(e3,tp)

    --Each time a card(s) is returned to the hand, or banished, by your card effect, gain 1 Virtual World Counter (max. 5).
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_TO_HAND)
    e4:SetCondition(s.repcon)
    e4:SetOperation(s.retop)
    Duel.RegisterEffect(e4, tp)

    local e5=e4:Clone()
    e5:SetCode(EVENT_REMOVE)
    Duel.RegisterEffect(e5, tp)


    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_MSET)
    e2:SetOperation(s.setstatuschange)
    Duel.RegisterEffect(e2,tp)

    --Count when cards leave the field
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_LEAVE_FIELD)
    e6:SetOperation(function(_,_,_eg,_,_,_,_,_) s.left_field_this_turn = s.left_field_this_turn + #_eg end)
    Duel.RegisterEffect(e6, tp)

end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsControler(tp) and (eg:IsExists(Card.IsLocation, 1, nil, LOCATION_REMOVED) or eg:IsExists(Card.IsLocation, 1, nil, LOCATION_HAND)) and eg:IsExists(Card.IsPreviousLocation, 1, nil, LOCATION_ONFIELD)
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp, id)<=5 then
		Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
			local ce=Duel.IsPlayerAffectedByEffect(tp,id)
			if ce then
				local nce=ce:Clone()
				ce:Reset()
				nce:SetDescription(aux.Stringid(id+1,Duel.GetFlagEffect(tp, id)+2))
				Duel.RegisterEffect(nce,tp)
			end
    end
end

function s.penguincontroledfilter(c,tp)
    return c:IsControler(tp) and c:IsSetCard(SET_PENGUIN)
end

function s.setstatuschange(e,tp,eg,ev,ep,re,r,rp)
    local g=eg:Filter(s.penguincontroledfilter, nil, tp)
	if #g>0 and Duel.GetTurnPlayer()==tp then
        for tc in g:Iter() do
			tc:SetStatus(STATUS_SUMMON_TURN, false)
            tc:SetStatus(STATUS_SPSUMMON_TURN,false)
            tc:SetStatus(STATUS_FORM_CHANGED,false)
		end
	end
end