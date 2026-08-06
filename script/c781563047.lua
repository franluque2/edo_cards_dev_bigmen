--Visions of the Legendary Planet
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
        s.used_this_skill_active = {}
        s.used_this_skill_active[0] = false
        s.used_this_skill_active[1] = false
        aux.AddValuesReset(function()
        s.used_this_skill_active[0] = false
        s.used_this_skill_active[1] = false
		end)

        end)


end

local VISION_FUSION=57425061
local CARD_GRAND_JUPITER=16255173

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()


    --the name of "Vision Fusion" is treated as "Polymerization" 
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetTargetRange(LOCATION_ALL, 0)
	e1:SetTarget(function(_, _c) return _c:IsOriginalCode(VISION_FUSION) end)
	e1:SetValue(CARD_POLYMERIZATION)
    Duel.RegisterEffect(e1, tp)


    --vision fusion gains the following effects in addition to its normal activation effect

    --Send 2 "Vision HERO" monster Cards from your Hand or face-up Field to the GY, and if you do, Special Summon 1 "The Grand Jupiter" from your Hand, Deck or GY.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCountLimit(1,VISION_FUSION,EFFECT_COUNT_CODE_OATH)
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
    e2:SetTarget(s.sptarg)
    e2:SetOperation(s.spoper)

    --Banish 2 "Vision HERO" Monster Cards from your Spell/Trap Zone, and if you do, place 1 monster from your GY or Extra Deck face-up in your Spell & Trap Zone as a Continuous Trap.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_ACTIVATE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCountLimit(1,VISION_FUSION,EFFECT_COUNT_CODE_OATH)
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE)
    e3:SetTarget(s.pltarg)
    e3:SetOperation(s.ploper)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e4:SetTargetRange(LOCATION_ALL,0)
    e4:SetTarget(function(_, _c) return _c:IsOriginalCode(VISION_FUSION) end)
    e4:SetLabelObject(e2)
    Duel.RegisterEffect(e4, tp)

    local e5=e4:Clone()
    e5:SetLabelObject(e3)
    Duel.RegisterEffect(e5, tp)

    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_ADJUST)
    e6:SetCondition(s.rewritevisionherocon)
    e6:SetOperation(s.rewritevisionheroop)
    Duel.RegisterEffect(e6, tp)
end

function s.rewritevisionherofilter(c)
    return c:IsSetCard(SET_VISION_HERO) and c:IsMonster() and c:GetFlagEffect(id)==0
end

function s.rewritevisionherocon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.rewritevisionherofilter,tp,LOCATION_ALL,0,1,nil)
end

function s.rewritevisionheroop(e,tp,eg,ep,ev,re,r,rp)
    	local g = Duel.GetMatchingGroup(s.rewritevisionherofilter, e:GetHandlerPlayer(), LOCATION_ALL, 0, nil)
	for tc in g:Iter() do
		local effs = { tc:GetOwnEffects() }
		for _, eff in ipairs(effs) do
			if eff:IsHasType(EFFECT_TYPE_IGNITION|EFFECT_TYPE_QUICK_O|EFFECT_TYPE_TRIGGER_O|EFFECT_TYPE_QUICK_F|EFFECT_TYPE_TRIGGER_F) and (eff:GetCost() ~= nil)
                and (eff:GetRange()&LOCATION_SZONE>0) then
				local neweff = eff:Clone()
				neweff:SetCost(s.repcostfunc(eff:GetCost()))
				eff:Reset()
				tc:RegisterEffect(neweff)
			end
		end
	end

end

function s.fugrandjupiterfilter(c)
    return c:IsCode(CARD_GRAND_JUPITER) and c:IsFaceup()
end


function s.repcostfunc(cost)
	return function(e, tp, eg, ep, ev, re, r, rp, chk)
		if chk == 0 then return cost(e, tp, eg, ep, ev, re, r, rp, 0) or (Duel.IsExistingMatchingCard(s.fugrandjupiterfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil) and Duel.GetFlagEffect(tp, id) > 0) end
		if Duel.IsExistingMatchingCard(s.fugrandjupiterfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil) and (not cost or not cost(e, tp, eg, ep, ev, re, r, rp, 0)
				or Duel.SelectYesNo(tp, aux.Stringid(id, 3))) then
			Duel.Hint(HINT_CARD, tp, id)
		else
			cost(e, tp, eg, ep, ev, re, r, rp, 1)
		end
	end
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)


    local g1 = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_DECK, 0, nil, 18094166)
	if #g1 > 0 then
		Duel.MoveToDeckTop(g1:GetFirst())
	end
end

function s.placevisionherofilter(c)
    return c:IsSetCard(SET_VISION_HERO) and c:IsMonster() and not c:IsForbidden()
end



function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    local g=Duel.GetMatchingGroup(s.placevisionherofilter,tp,LOCATION_HAND,0,nil)
    return (#g>0) and (not s.used_this_skill_active[e:GetHandlerPlayer()])  and aux.CanActivateSkill(tp) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    s.used_this_skill_active[e:GetHandlerPlayer()] = true
    Duel.Hint(HINT_CARD, tp, id)
    local c = e:GetHandler()

    local g=Duel.GetMatchingGroup(s.placevisionherofilter,tp,LOCATION_HAND,0,nil)
    local num=Duel.GetLocationCount(tp, LOCATION_SZONE)
    if #g>0 and num>0 then
        if num>2 then num=2 end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
        local g2=g:Select(tp, 1, 2, nil)
        for tc in g2:Iter() do
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
            e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
            tc:RegisterEffect(e1)

        end
    end
end

function s.visionheromonstercardtogravefilter(c)
    return c:IsSetCard(SET_VISION_HERO) and c:IsMonster() and c:IsAbleToGrave() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end

function s.spfilter(c,e,tp)
    return c:IsCode(CARD_GRAND_JUPITER)
end

function s.sptarg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.visionheromonstercardtogravefilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,nil,SET_VISION_HERO) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spoper(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.visionheromonstercardtogravefilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,2,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.placefilter(c)
    return c:IsMonster() and not c:IsForbidden()
end

function s.rmvisionherofilter(c)
    return c:IsSetCard(SET_VISION_HERO) and c:IsAbleToRemove() and c:IsOriginalType(TYPE_MONSTER)
end

function s.pltarg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmvisionherofilter,tp,LOCATION_SZONE,0,2,nil) and Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_EXTRA|LOCATION_EXTRA,0,1,nil) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_SZONE)
end

function s.ploper(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmvisionherofilter,tp,LOCATION_SZONE,0,2,2,nil)
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local sg=Duel.SelectMatchingCard(tp,s.placefilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
        if #sg>0 then
            local tc=sg:GetFirst()
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
            e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
            tc:RegisterEffect(e1)

        end
    end
end