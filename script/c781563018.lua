--Miracles of Hope
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
	

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,s.flipconactive, s.flipopactive, true, nil)

	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

    aux.GlobalCheck(s, function()
		s.used_this_skill = {}
        s.used_this_skill[0] = false
        s.used_this_skill[1] = false

        aux.AddValuesReset(function()
			s.used_this_skill[0] = false
			s.used_this_skill[1] = false
		end)

    end)
end

local CARD_UTOPIC_DRAGON=51543904
local friend_xyzs={49032236,1992816,31801517,88120966,9161357,39139935,77571454,2061963,49678559,59627393,94380860,32003339,39972129,48928529,54366836,82308875,75433814,88177324,65676461,76067258,11411223,63746411,80117527,64554883,}
local friend_xyz_to_summon={}
friend_xyz_to_summon[0]=Group.CreateGroup()
friend_xyz_to_summon[1]=Group.CreateGroup()

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()
    
    s.filltables()

    --Xyz Monsters in your possession are treated as "Utopia" monsters
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ADD_SETCODE)
    e1:SetTargetRange(LOCATION_ALL, 0)
    e1:SetTarget(function(_, c) return c:IsType(TYPE_XYZ) end)
    e1:SetValue(SET_UTOPIA)
    Duel.RegisterEffect(e1, tp)

    	local e5 = Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCondition(s.repcon2)
	e5:SetOperation(s.repop)
	Duel.RegisterEffect(e5, tp)

    --The Special Summon effect of your "Number 99: Utopic Dragon" does not negate the effect of the monster summoned.
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    e6:SetCondition(s.utopic_summon_condition)
    e6:SetOperation(s.utopic_summon_operation)
    Duel.RegisterEffect(e6, tp)

end

function s.filltables()
    if #friend_xyz_to_summon[0] > 0 then return end
    for i = 0, 1, 1 do
        for _, friend in ipairs(friend_xyzs) do
            local friend_card = Duel.CreateToken(i, friend)
            friend_xyz_to_summon[i]:AddCard(friend_card)
        end
    end
end

function s.fuutopicdragonfilter(c)
    return c:IsCode(CARD_UTOPIC_DRAGON) and c:IsFaceup()
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    return (not s.used_this_skill[e:GetHandlerPlayer()]) and aux.CanActivateSkill(e:GetHandlerPlayer()) and Duel.IsExistingMatchingCard(s.fuutopicdragonfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    s.used_this_skill[e:GetHandlerPlayer()] = true
    Duel.Hint(HINT_CARD, tp, id)
	local num1=Duel.GetRandomNumber(1, #friend_xyz_to_summon[tp] )
	local num2=Duel.GetRandomNumber(1, #friend_xyz_to_summon[tp] )
	while num2==num1 do
		num2=Duel.GetRandomNumber(1, #friend_xyz_to_summon[tp] )
	end
	local num3=Duel.GetRandomNumber(1, #friend_xyz_to_summon[tp] )
	while num3==num2 or num3==num1 do
		num3=Duel.GetRandomNumber(1, #friend_xyz_to_summon[tp] )
	end
    local randomfriends=Group.CreateGroup()
    randomfriends:AddCard(friend_xyz_to_summon[tp]:TakeatPos(num1-1))
    randomfriends:AddCard(friend_xyz_to_summon[tp]:TakeatPos(num2-1))
    randomfriends:AddCard(friend_xyz_to_summon[tp]:TakeatPos(num3-1))
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local to_summon = randomfriends:Select(tp, 1, 1, nil):GetFirst()
    local token=Duel.CreateToken(tp, to_summon:GetCode())
    Duel.SendtoGrave(token, REASON_RULE)
    Card.CompleteProcedure(token)
end


function s.cardfilter(c, tp)
    return c:IsCode(04647954)
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.cardfilter, tp, LOCATION_DECK, 0, nil, tp)
    if #g == Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) then return end
    if #g > 0 then
        Duel.MoveToDeckTop(g:GetFirst())
    end
end

function s.protectfilter(c, tp)
	return c:IsFaceup() and (c:IsCode(CARD_UTOPIC_DRAGON)) and c:IsControler(tp)
end


function s.massleavecheck(tp)
	local categories = { CATEGORY_TOHAND, CATEGORY_DESTROY, CATEGORY_REMOVE, CATEGORY_TODECK, CATEGORY_RELEASE, CATEGORY_TOGRAVE }
	for _, category in ipairs(categories) do
		local ex, tg = s.leaveChk(tp, category)
		if ex and tg and #tg > 0 then
			return true, tg
		end
	end
end

function s.massleavecheck2(tp)
	local categories = { CATEGORY_TOHAND, CATEGORY_DESTROY, CATEGORY_REMOVE, CATEGORY_TODECK, CATEGORY_RELEASE, CATEGORY_TOGRAVE }
	for _, category in ipairs(categories) do
		local ex, tg = s.leaveChk2(tp, category)
		if ex and tg and #tg > 0 then
			return true, tg
		end
	end
end

function s.leaveChk(tp, category)
	local ex,tg=Duel.GetOperationInfo(0,category)
	if tg then
		return ex and tg~=nil and tg:IsExists(s.protectfilter, 1, nil, tp), tg:Filter(s.protectfilter, nil, tp)
	else
	 	return false, nil
	end
end

function s.leaveChk2(tp, category)
	local ex,tg=Duel.GetPossibleOperationInfo(0,category)
	if tg then
		return ex and tg~=nil and tg:IsExists(s.protectfilter, 1, nil, tp), tg:Filter(s.protectfilter, nil, tp)
	else
	 	return false, nil
	end
end

function s.repfilter(c)
    return c:IsSetCard(SET_ZW) and c:IsFaceup() and c:IsAbleToRemove()
end

function s.repcon2(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.IsExistingMatchingCard(s.repfilter, tp, LOCATION_ONFIELD, 0, 1, nil) then return false end
	local includesCard, tg = s.massleavecheck(tp)
	if includesCard then
		e:SetLabelObject(tg)
		return true
	end
	includesCard, tg = s.massleavecheck2(tp)
	if includesCard then
		e:SetLabelObject(tg)
		return true
	end

	return includesCard
end



function s.repop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local g2 = e:GetLabelObject()
	if #g2 == 0 then return end
	if not Duel.IsExistingMatchingCard(s.repfilter, tp, LOCATION_ONFIELD, 0, 1, nil) then return end
	if g2 then
		for tc in g2:Iter() do
			Duel.HintSelection(tc)
			if Duel.IsExistingMatchingCard(s.repfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
				Duel.Hint(HINT_CARD, tp, id)
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
                local rg=Duel.SelectMatchingCard(tp, s.repfilter, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
                Duel.Remove(rg, POS_FACEUP, REASON_EFFECT)
				local e2 = Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e2:SetRange(LOCATION_MZONE)
				e2:SetCode(EFFECT_IMMUNE_EFFECT)
				e2:SetReset(RESET_CHAIN)
				e2:SetValue(s.efilter)
				tc:RegisterEffect(e2)
			end
		end
	end
end


function s.efilter(e, te)
	return te:GetOwner() ~= e:GetOwner()
end

function s.utopic_summon_condition(e, tp, eg, ep, ev, re, r, rp)
    return re and re:IsActivated() and re:GetHandler():IsCode(CARD_UTOPIC_DRAGON) and re:GetHandlerPlayer() == tp
end

function s.utopic_summon_operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = eg:GetFirst()
    if not tc:IsFaceup() then return end

    local effs={tc:GetCardEffect(EFFECT_DISABLE)}
    for _, eff in ipairs(effs) do
        eff:Reset()
    end

    effs={tc:GetCardEffect(EFFECT_DISABLE_EFFECT)}
    for _, eff in ipairs(effs) do
        eff:Reset()
    end

end
