--Forbidden Beast Nibunu (CT) - NO CODE
local s,id=GetID()
function s.initial_effect(c)
	--change type yto beast
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e4:SetCondition(s.spcon)
	e4:SetValue(RACE_BEAST)
	c:RegisterEffect(e4)

end

function s.spcon(e)
	if e==nil then return true end
	return Duel.IsPlayerAffectedByEffect(e:GetHandler():GetControler(),511000380)
end
