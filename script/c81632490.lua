--Deep Space Yggdrago (CT)
Duel.LoadScript("big_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,SPACE_YGGDRAGO,3)


    --indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)

    --pierce
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)

    --Decrease the ATK
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetTarget(s.adtg)
	e6:SetValue(-1000)
	c:RegisterEffect(e6)

end


function s.adtg(e,c)
	return c:IsLevelAbove(7) or c:IsRankAbove(7) or c:IsLinkAbove(3)
end