--Last King of Atlantis
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

    --aux.GlobalCheck(s, function()
    --    s.used_this_skill = {}
    --    s.used_this_skill[0] = false
    --    s.used_this_skill[1] = false
    --
    --    aux.AddValuesReset(function()
	--		s.used_this_skill[0] = false
	--		s.used_this_skill[1] = false
	--	end)
    --end)

    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, s.flipconactive, s.flipopactive, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

local ORICHALCOS_FIELDS={48179391, 110000100, 110000101}


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.placecards(e,tp)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritefieldcon)
    e1:SetOperation(s.rewritefieldop)
    Duel.RegisterEffect(e1,tp)

    local e2=e1:Clone()
    e2:SetCondition(s.rewritefieldsonfieldcon)
    e2:SetOperation(s.rewritefieldsonfieldop)
    Duel.RegisterEffect(e2,tp)

    --Neither Player can activate cards or effects when you activate an "Orichalcos" Field Spell
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetOperation(s.chainop)
    Duel.RegisterEffect(e3,tp)

    --Orichalcos" Field Spells you control are unaffected by your opponent's card effects (except Level 8 or higher Warrior monsters')
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetTargetRange(LOCATION_ONFIELD,0)
    e4:SetTarget(function (_,c) return c:IsCode(table.unpack(ORICHALCOS_FIELDS)) end)
    e4:SetValue(function (e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and not (te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsLevelAbove(8) and te:GetHandler():IsRace(RACE_WARRIOR)) end)
    Duel.RegisterEffect(e4,tp)

    --If you Normal or Special Summon a level 6 or lower monster(s), you can place 1 of them in your Spell & Trap Zone as a Continuous Spell
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_SUMMON_SUCCESS)
    e5:SetCondition(s.placecon)
    e5:SetOperation(s.placeop)
    Duel.RegisterEffect(e5,tp)

    local e6=e5:Clone()
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    Duel.RegisterEffect(e6,tp)

    --During their Battle Phase, if you control no monsters your opponent can activate this effect (Quick Effect): Special Summon 1 Monster Card you control in your Spell & Trap Zone to your field of your opponent's choice.
    local e7 = Effect.CreateEffect(e:GetHandler())
    e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetProperty(EFFECT_FLAG_DELAY)
    e7:SetCondition(s.spsummoncon)
    e7:SetOperation(s.spsummonop)
    Duel.RegisterEffect(e7, 1-tp)
end


function s.placecards(e,tp)
        local field=Duel.CreateToken(tp, 48179391)
        Duel.MoveToField(field, tp, tp, LOCATION_FZONE, POS_FACEUP, true)

end

function s.banishfilter(c,tp)
    return c:IsAbleToRemoveAsCost() and not c:IsType(TYPE_FIELD)
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    return aux.CanActivateSkill(tp)
        and Duel.IsExistingMatchingCard(s.banishfilter, tp, LOCATION_HAND, 0, 1, nil,tp)
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, tp, id)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp, s.banishfilter, tp, LOCATION_HAND, 0, 1, 1, nil,tp)
    if #g>0 then
        Duel.Remove(g, POS_FACEDOWN, REASON_COST)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local code=Duel.SelectCardsFromCodes(tp,1,1,false,false,table.unpack(ORICHALCOS_FIELDS))

    local token=Duel.CreateToken(tp, code)
    Duel.SendtoHand(token, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, token)

end


function s.orichalcosfieldfilter(c)
    return c:IsCode(table.unpack(ORICHALCOS_FIELDS)) and c:GetFlagEffect(id)==0
end

function s.orichalcosfieldupgradefilter(c)
    if not (c:IsCode(table.unpack(ORICHALCOS_FIELDS)) and c:GetFlagEffect(id+1)==0) then
        return false
    end
    local effs={c:GetOwnEffects()}
    for _, eff in ipairs(effs) do
        if Effect.IsHasType(eff,EFFECT_TYPE_TRIGGER_O) then
            return true
        end
        if Effect.IsHasType(eff,EFFECT_TYPE_QUICK_O) then
            return true
        end

        if Effect.GetCode(eff)==EFFECT_CANNOT_SELECT_BATTLE_TARGET then
            return true
        end
    end
    return false

end

function s.rewritefieldcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.orichalcosfieldfilter,tp,LOCATION_ALL,0,1,nil)
end

function s.rewritefieldop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.orichalcosfieldfilter,tp,LOCATION_ALL,0,nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,0,0,aux.Stringid(id, 0))
        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
			if Effect.IsHasType(eff,EFFECT_TYPE_ACTIVATE) then
                eff:SetCountLimit(1,id)
                if tc:IsCode(48179391) then
                    eff:SetTarget(aux.TRUE)
                    eff:SetOperation(aux.TRUE)
                end
            end
            if Effect.IsHasType(eff,EFFECT_TYPE_TRIGGER_O) then
                eff:SetCountLimit(1)
            end
            if Effect.IsHasType(eff,EFFECT_TYPE_QUICK_O) then
                eff:SetCountLimit(1)
            end

            if Effect.GetCode(eff)==EFFECT_CANNOT_SELECT_BATTLE_TARGET then
                eff:Reset()
            end

        end
    end
end

function s.rewritefieldsonfieldcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.orichalcosfieldupgradefilter,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.rewritefieldsonfieldop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.orichalcosfieldupgradefilter,tp,LOCATION_ONFIELD,0,nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,0)
        local effs={tc:GetOwnEffects()}
        for _, eff in ipairs(effs) do
            if Effect.IsHasType(eff,EFFECT_TYPE_TRIGGER_O) then
                eff:SetCountLimit(1)
            end
            if Effect.IsHasType(eff,EFFECT_TYPE_QUICK_O) then
                eff:SetCountLimit(1)
            end

            if Effect.GetCode(eff)==EFFECT_CANNOT_SELECT_BATTLE_TARGET then
                eff:Reset()
            end

        end
    end
end


function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and (rc:IsCode(table.unpack(ORICHALCOS_FIELDS))) then
		Duel.SetChainLimit(aux.FALSE)
	end
end

function s.placecon(e,tp,eg,ep,ev,re,r,rp)
    return tp==ep and eg:IsExists(function(c) return c:IsLevelBelow(6) and c:IsControler(tp) and c:GetSummonPlayer()==tp end, 1, nil)
end

function s.placeop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp, LOCATION_SZONE)>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_CARD,tp,id)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
        local g=eg:FilterSelect(tp,function(c) return c:IsLevelBelow(6) and c:IsControler(tp) and c:GetSummonPlayer()==tp end,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            local tc=g:GetFirst()
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        
        
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
        e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
        tc:RegisterEffect(e1)

        local effs={tc:GetOwnEffects()}
        for _,eff in ipairs(effs) do
            if Effect.GetRange(eff)&LOCATION_MZONE==LOCATION_MZONE then
                local neweff=eff:Clone()
                neweff:SetRange(LOCATION_SZONE)
                neweff:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(neweff)
            end
        end

        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,0,0,aux.Stringid(id, 4))
        end

    end
end


function s.spsummonfilter(c,e,tp)
    return c:IsMonsterCard() and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spsummoncon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase() and Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)==0
        and Duel.IsExistingMatchingCard(s.spsummonfilter,1-tp,LOCATION_SZONE,0,1,nil,e,1-tp)
        and Duel.IsTurnPlayer(tp) and Duel.GetCurrentChain()==0
end

function s.spsummonop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_CARD,1-tp,id)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spsummonfilter,1-tp,LOCATION_SZONE,0,1,1,nil,e,1-tp)
        if #g>0 then
            Due.HintSelection(g)
            Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP)
        end
    end
end