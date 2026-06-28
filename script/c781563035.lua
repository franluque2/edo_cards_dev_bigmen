--Ceremonial Mirrors of Fate
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)

        local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,nil,nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

local SPIRIT_SERVANTS={511000937,511000936,511000918,511000917}
local DARK_CREATOR=52768390
local DARK_CREATOR_TOKEN=DARK_CREATOR+1
local FULL_MOON_MIRROR=44857722
local COUNTER_FULL_MOON=0x219

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.placecards(c,e,tp)


    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1, tp)


end

function s.placecards(c,e,tp)
    for _, code in ipairs(SPIRIT_SERVANTS) do
        local token=Duel.CreateToken(tp, code)
        Duel.SendtoGrave(token, REASON_RULE)

        local e1=Effect.CreateEffect(c)
        e1:SetCode(EFFECT_ADD_SETCODE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
        e1:SetValue(SET_DREAM_MIRROR)
        token:RegisterEffect(e1)
    end

    local fiendmirrortoken=Duel.CreateToken(tp, FULL_MOON_MIRROR)
	Duel.MoveToField(fiendmirrortoken,tp,tp,LOCATION_SZONE,POS_FACEUP,true)

    local effs={fiendmirrortoken:GetOwnEffects()}
    for _, eff in ipairs(effs) do
        if (eff:GetCode()&EVENT_DESTROYED)==EVENT_DESTROYED then
            local addedeff=eff:Clone()
            addedeff:SetCode(EVENT_RELEASE)
            addedeff:SetOperation(s.ctop)
            fiendmirrortoken:RegisterEffect(addedeff)
        end
    end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(3100)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_SZONE)
    e1:SetValue(function(_e,_re) return _e:GetHandler()~=_re:GetHandler() end)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    fiendmirrortoken:RegisterEffect(e1)

    fiendmirrortoken:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id, 1))


    local dcreatortoken=Duel.CreateToken(tp, DARK_CREATOR)
    Duel.SendtoHand(dcreatortoken, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, dcreatortoken)
end

function s.torewritefilter(c)
    return c:IsSetCard(SET_DREAM_MIRROR) and c:IsOriginalType(TYPE_MONSTER) and (c:GetFlagEffect(id) == 0)
end

function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.torewritefilter, tp, LOCATION_ALL, 0, 1, nil)
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.torewritefilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)
        local effs={tc:GetOwnEffects()}

        for _, eff in ipairs(effs) do
            if (eff:GetCode()&EVENT_SPSUMMON_SUCCESS)==EVENT_SPSUMMON_SUCCESS then
                if eff:GetCondition() then
                    --local eff1=eff:Clone()
                    local oldcondition=eff:GetCondition()
                    eff:SetCondition(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp) return (oldcondition(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)) or (_re and _re:GetHandler():IsCode(FULL_MOON_MIRROR)) end)
                    --eff:Reset()
                    --tc:RegisterEffect(eff1)
                end
            end

            if eff:GetCost() then
                if eff:GetCost()==Cost.SelfRelease then                
                local neweff = eff:Clone()
				neweff:SetCost(s.repcostfunc(eff:GetCost()))
				eff:Reset()
				tc:RegisterEffect(neweff)
                end
            end
        end
    end
end

function s.releasereplacefilter(c)
    return c:IsReleasableByEffect() and c:IsCode(DARK_CREATOR_TOKEN,table.unpack(SPIRIT_SERVANTS))
end

function s.repcostfunc(cost)
	return function(e, tp, eg, ep, ev, re, r, rp, chk)
		if chk == 0 then return cost(e, tp, eg, ep, ev, re, r, rp, 0) or Duel.IsExistingMatchingCard(s.releasereplacefilter, tp, LOCATION_MZONE, 0, 1, nil) end
		if Duel.IsExistingMatchingCard(s.releasereplacefilter, tp, LOCATION_MZONE, 0, 1, nil)
				and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
			Duel.Hint(HINT_CARD, tp, id)
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
            local g=Duel.SelectMatchingCard(tp, s.releasereplacefilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
            Duel.Release(g, REASON_COST)
		else
			cost(e, tp, eg, ep, ev, re, r, rp, 1)
		end
	end
end


function s.ctfilter(c)
	return c:IsMonster() and c:IsReason(REASON_RELEASE)
end


function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local des_count=eg:FilterCount(s.ctfilter,nil)
	if des_count==0 then return end
	local c=e:GetHandler()
	if not Duel.IsChainSolving() then
		c:AddCounter(COUNTER_FULL_MOON,des_count)
	else
		--Place 1 Full Moon Counter on this card at the end of the Chain Link
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetRange(LOCATION_SZONE)
		e1:SetOperation(function() c:AddCounter(COUNTER_FULL_MOON,des_count) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		c:RegisterEffect(e1)
		--Reset "e1" at the end of the Chain Link
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetOperation(function() e1:Reset() end)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end