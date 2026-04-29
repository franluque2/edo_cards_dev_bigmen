--Swinging into Action!
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,
        nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end

function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))

    local c = e:GetHandler()

    if Duel.IsDuelType(0x2000) then
	--link zones
		local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_BECOME_LINKED_ZONE)
		e6:SetRange(LOCATION_FZONE)
		e6:SetValue(s.value)
		Duel.RegisterEffect(e6,tp)

		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_FORCE_MZONE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetTargetRange(1,0)
		e3:SetValue(s.znval)
		Duel.RegisterEffect(e3,tp)
    end
end

function s.znval(e)
	return ~(0x60)
end

function s.value(e)
	return 0x1f<<16*e:GetHandlerPlayer()
end