--Tag Out!
local s,id=GetID()
function s.initial_effect(c)

    	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_ALL)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)

    local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetRange(LOCATION_ALL)
		e1:SetCode(EFFECT_CANNOT_TO_DECK)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_TO_HAND)
		c:RegisterEffect(e2)

        local e3=e1:Clone()
        e3:SetCode(EFFECT_CANNOT_TO_GRAVE) 
        c:RegisterEffect(e3)

        local e5=e1:Clone()
        e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        c:RegisterEffect(e5)

        local e6=e1:Clone()
        e6:SetCode(EFFECT_CANNOT_USE_AS_COST)
        c:RegisterEffect(e6)

        local e10=Effect.CreateEffect(c)
        e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e10:SetCode(EVENT_FREE_CHAIN)
        e10:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE)
        e10:SetRange(LOCATION_ALL)
        e10:SetCondition(function (e,tp) return aux.CanActivateSkill(tp) end)
        e10:SetOperation(s.flipopactive)
        c:RegisterEffect(e10)

        local e11=e10:Clone()
        e11:SetType(EFFECT_TYPE_QUICK_O)
        e11:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
        e11:SetCost(s.fakecostfunc)
        e11:SetCondition(function (e,tp) return not aux.CanActivateSkill(tp) end)
        e11:SetOperation(aux.TRUE)
        c:RegisterEffect(e11)
	
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
            local op=Duel.SelectEffect(tp, {true, aux.Stringid(id-1,0)},
            {true, aux.Stringid(id-1,1)})
            if op==1 then
                Duel.Hint(HINT_CARD,tp,id)
                Duel.TagSwap(tp)
            end
end


function s.fakecostfunc(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
        Duel.TagSwap(tp)
        Duel.RegisterFlagEffect(0, id, RESET_CHAIN, 0, 1)
end

local oldfunc=Duel.GetCurrentChain
function Duel.GetCurrentChain(...)
    return oldfunc(...)-(Duel.GetFlagEffect(0, id))
end


local oldfunc2=Duel.CheckChainUniqueness
function Duel.CheckChainUniqueness(...)
    if Duel.GetFlagEffect(0, id)>0 then
        local num=oldfunc(false)
        local resolvedeffs={}
        for i = 1,num do
            local code=Duel.GetChainInfo(i, CHAININFO_TRIGGERING_CODE)
            if code and code~=id then
                if not resolvedeffs[code] then
                    resolvedeffs[code]=true
                else
                    return false
                end
            end
        end
        return true
    else
        return oldfunc2(...)
    end
end