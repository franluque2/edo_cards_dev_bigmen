--Knowledge of the Wisdom God
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
end

function s.nottopdeckcardfilter(c,seq)
    return c:IsSpellTrap() and c:GetSequence() < seq
end

function s.shuffledownop(e, tp, eg, ep, ev, re, r, rp)

    local topdeck=Duel.GetDecktopGroup(tp, Duel.GetStartingHand(tp))
    local num=topdeck:FilterCount(Card.IsMonster,nil)
    if num>2 then
        local g=Duel.GetMatchingGroup(s.nottopdeckcardfilter, tp, LOCATION_DECK, 0, nil, Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-Duel.GetStartingHand(tp))
        local newtopdeck=topdeck:Filter(Card.IsMonster,nil):RandomSelect(tp, 2)
        local g2=g:RandomSelect(tp, Duel.GetStartingHand(tp)-2)
        newtopdeck:Merge(g2)
        Duel.MoveToDeckTop(newtopdeck)
    end

end


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    s.addbeasts(e,tp)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(s.rewritecardscon)
    e1:SetOperation(s.rewritecardsop)
    Duel.RegisterEffect(e1,tp)
end


function s.addbeasts(e,tp)
    local token1=Duel.CreateToken(tp, 91697229)
    local token2=Duel.CreateToken(tp, 64203620)

    local g=Group.FromCards(token1,token2)
    Duel.SendtoHand(g, tp, REASON_RULE)
    Duel.ConfirmCards(1-tp, g)
end

function s.rewritegullveigfilter(c)
    return c:IsCode(90207654) and c:GetFlagEffect(id)==0
end

function s.rewriteaesirfilter(c)
    return c:IsSetCard(SET_AESIR) and c:GetFlagEffect(id)==0
end


function s.rewritecardscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.rewritegullveigfilter,tp,LOCATION_ALL,0,1,nil) or Duel.IsExistingMatchingCard(s.rewriteaesirfilter,tp,LOCATION_ALL,0,1,nil)
end

function s.rewritecardsop(e,tp,eg,ep,ev,re,r,rp)
    local g1 = Duel.GetMatchingGroup(s.rewritegullveigfilter, e:GetHandlerPlayer(), LOCATION_ALL, 0, nil)
    for tc in g1:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)
        local effs = { tc:GetOwnEffects() }
        for _, eff in ipairs(effs) do
            if eff:IsHasType(EFFECT_TYPE_TRIGGER_O) then
                
                local neweff=eff:Clone()
                neweff:SetCondition(aux.TRUE)
                neweff:SetCountLimit(1)

                eff:Reset()

                tc:RegisterEffect(neweff)

            end
            
        end

            local e0=Effect.CreateEffect(e:GetHandler())
            e0:SetType(EFFECT_TYPE_FIELD)
            e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
            e0:SetDescription(aux.Stringid(id,2))
            e0:SetCode(EFFECT_SPSUMMON_PROC)
            e0:SetRange(LOCATION_EXTRA)
            e0:SetCondition(s.hspcon)
            e0:SetTarget(s.hsptg)
            e0:SetOperation(s.hspop)
            tc:RegisterEffect(e0)

    end

    local g2 = Duel.GetMatchingGroup(s.rewriteaesirfilter, e:GetHandlerPlayer(), LOCATION_ALL, 0, nil)
    for tc in g2:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)
        local effs = { tc:GetOwnEffects() }
        for _, eff in ipairs(effs) do

            if eff:IsHasType(EFFECT_TYPE_IGNITION) then
                local neweff=eff:Clone()
                neweff:SetDescription(aux.Stringid(id,0))
                neweff:SetType(EFFECT_TYPE_QUICK_O)
                neweff:SetCode(EVENT_FREE_CHAIN)
                neweff:SetHintTiming(0|TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
                if eff:GetCost() then
                    neweff:SetCost(s.repcostfunc(eff:GetCost()))
                end
                tc:RegisterEffect(neweff)

            end

            if eff:GetRange()&LOCATION_GRAVE>0 then
                local neweff=eff:Clone()
                neweff:SetCost(s.repcostfunc(eff:GetCost()))
				eff:Reset()
				tc:RegisterEffect(neweff)
            end

        end
    end

end

function s.repcostfunc(cost)
	return function(e, tp, eg, ep, ev, re, r, rp, chk)
		if chk == 0 then return (cost and cost(e, tp, eg, ep, ev, re, r, rp, 0)) or ( Duel.GetFlagEffect(tp, id) > 0) end
		if (not cost or not cost(e, tp, eg, ep, ev, re, r, rp, 0)
				or Duel.SelectYesNo(tp, aux.Stringid(id, 1))) then
			Duel.Hint(HINT_CARD, tp, id)
		else
			cost(e, tp, eg, ep, ev, re, r, rp, 1)
		end
	end
end

function s.costfilter(c)
    return c:IsFacedown() and c:IsAbleToGraveAsCost()
end


function s.costfunc(e,tp,eg,ep,ev,re,r,rp,chk)
    --by Sending 1 face-down card from your Spell & Trap Zone to the GY when activating their effects.
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end




function s.tobanishfilter(c)
	return c:IsAbleToRemoveAsCost()
end

function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.tobanishfilter, tp, LOCATION_HAND, 0,1, nil)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectMatchingCard(tp,s.tobanishfilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Remove(g, POS_FACEDOWN, REASON_COST+REASON_MATERIAL)
	c:SetMaterial(g)
	c:RegisterFlagEffect(id, RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD, 0, 0)
	g:DeleteGroup()
end