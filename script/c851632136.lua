--Lhrash, Herald of Invasion
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	

    c:EnableReviveLimit()
	--Link Summon Procedure
	Link.AddProcedure(c,s.matfilter,1,1)
	--You can only Special Summon "Fiendsmith Requiem(s)" once per turn
	c:SetSPSummonOnce(id)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetOperation(s.chngcon)
	e1:SetValue(SET_TECHMINATOR)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(id+1)
    c:RegisterEffect(e3)

end
s.listed_series={SET_TECHMINATOR, SET_DIKTAT}

function s.chngcon(scard,sumtype,tp)
	return (sumtype&SUMMON_TYPE_LINK|MATERIAL_LINK)==SUMMON_TYPE_LINK|MATERIAL_LINK
end

function s.matfilter(c,lc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp) and c:IsRace(RACE_MACHINE,lc,sumtype,tp)
end