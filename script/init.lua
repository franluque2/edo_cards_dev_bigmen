-- The Special Summon of a card with this effect cannot be prevented
EFFECT_CAN_ALWAYS_SPECIAL_SUMMON=811632989

local function splimit(target)
	return function (e,c,...)
		return not c:IsHasEffect(EFFECT_CAN_ALWAYS_SPECIAL_SUMMON) and (not target or target(e,c,...))
	end
end

local oldcf=Card.RegisterEffect
Card.RegisterEffect=function(c,e,...)
    if e:GetCode()==EFFECT_CANNOT_SPECIAL_SUMMON then
        local oldTg=e:GetTarget()
        e:SetTarget(splimit(oldTg))
    end

    if e:GetCode()==EFFECT_FORCE_SPSUMMON_POSITION then
        local oldTg=e:GetTarget()
        e:SetTarget(splimit(oldTg))
    end
    return oldcf(c,e,...)
end
local oldpf=Duel.RegisterEffect
Duel.RegisterEffect=function(e,p)
    if e:GetCode()==EFFECT_CANNOT_SPECIAL_SUMMON then
        local oldTg=e:GetTarget()
        e:SetTarget(splimit(oldTg))
    end

    if e:GetCode()==EFFECT_FORCE_SPSUMMON_POSITION then
        local oldTg=e:GetTarget()
        e:SetTarget(splimit(oldTg))
    end
    return oldpf(e,p)
end