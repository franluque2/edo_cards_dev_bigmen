--Winds of a Higher Plane
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


	local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
		s.flipconactive, s.flipopactive, true, nil)
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.revfilter(c)
    return c:IsOriginalCode(86327225) and not c:IsPublic()
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    return (not s.used_this_skill[e:GetHandlerPlayer()]) and aux.CanActivateSkill(e:GetHandlerPlayer()) and Duel.IsExistingMatchingCard(s.revfilter, tp, LOCATION_HAND, 0, 1, nil)
end


function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
	Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

	local c = e:GetHandler()
    s.addtypetocards(c, tp)

    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetTargetRange(LOCATION_HAND, 0)
    e1:SetValue(52900000)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsOriginalCode, 86327225))
    Duel.RegisterEffect(e1, tp)

    local e7=Effect.CreateEffect(e:GetHandler())
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_CANNOT_TRIGGER)
    e7:SetTargetRange(LOCATION_MZONE,0)
    e7:SetCondition(s.discon)
    e7:SetTarget(s.actfilter)
    Duel.RegisterEffect(e7, tp)

    	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_RELEASE)
	e8:SetCondition(s.thcon)
	e8:SetOperation(s.thop)
    Duel.RegisterEffect(e8, tp)

    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e9:SetTargetRange(LOCATION_ALL, 0)
    e9:SetValue(ATTRIBUTE_WIND)
    e9:SetTarget(aux.TargetBoolFunction(Card.IsOriginalCode, 86327225))
    Duel.RegisterEffect(e9, tp)
end

function s.todeckfilter(c)
    return (c:IsType(TYPE_SPIRIT) or c:IsOriginalCode(86327225)) and c:IsAbleToDeck()
end

function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsOriginalCode,1,nil,86327225)
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_CARD, tp, id)

	s.used_this_skill[tp] = true

	local g=Duel.GetMatchingGroup(s.todeckfilter, tp, LOCATION_HAND, 0, nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	    local sg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,1,tp,HINTMSG_TODECK)
        local totallp=#sg*1500
        Duel.ConfirmCards(1-tp, sg)
		Duel.Recover(tp,totallp,REASON_RULE)
        Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        Duel.Draw(tp, #sg, REASON_EFFECT)
    end

end

local oldfunc=Card.IsType

function Card.IsType(c, t)
    if c:IsOriginalCode(86327225) and ((t&TYPE_SPIRIT)==TYPE_SPIRIT) and c:GetFlagEffect(id-1000) then return true end
    return oldfunc(c, t)
end


function s.discon(e)
	return Duel.IsMainPhase()
end

function s.actfilter(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsMonster() and c:IsLevel(8) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPIRIT) and c:GetFlagEffect(id) == 0
end

function s.shinatotributefilter(c)
    return c:IsOriginalCode(86327225) and c:IsReason(REASON_RITUAL)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.shinatotributefilter, 1, nil)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:Filter(s.shinatotributefilter, nil):GetFirst()
    if not tc then return end
    local rc=tc:GetReasonCard()
    if not rc then return end
    Card.RegisterFlagEffect(rc, id, RESET_EVENT+RESETS_STANDARD, 0, 1)
end


function s.addtypetocards(c,tp)
    local g=Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ALL, 0, nil, 86327225)
    for tc in g:Iter() do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e1:SetCode(EFFECT_ADD_TYPE)
        e1:SetValue(TYPE_SPIRIT)
        tc:RegisterEffect(e1)

        tc:RegisterFlagEffect(id-1000, 0, 0, 0)
    end
end