--Minecraft Contraption: Barrier Block
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,TIMING_STANDBY_PHASE|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
		

    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_DISABLE_FIELD)
	e4:SetProperty(EFFECT_FLAG_REPEAT)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)

    c:SetUniqueOnField(1,0,id)


end


function s.disop(e,tp)
	local c=e:GetHandler()
	local zone=c:GetColumnZone(LOCATION_ONFIELD)
	for tc in e:GetHandler():GetColumnGroup():Iter() do
		local dz=tc:IsLocation(LOCATION_MZONE) and 1 or (1 << 8)
		if tc:IsSequence(5,6) then
			local dz1=tc:IsControler(tp) and (dz << tc:GetSequence()) or (dz << (16 + tc:GetSequence()))
			local dz2=tc:IsControler(tp) and (dz << (16 + (11 - tc:GetSequence()))) or (dz << (11 - tc:GetSequence()))
			dz=dz1|dz2
		else
			dz=tc:IsControler(tp) and (dz << tc:GetSequence()) or (dz << (16 + tc:GetSequence()))
		end
		zone=zone&~dz
	end
	return zone
end
