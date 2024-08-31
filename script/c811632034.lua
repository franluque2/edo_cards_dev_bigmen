--This is a Real Xyz Material
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(511002116)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(511002961)
    e4:SetRange(LOCATION_SZONE)
    c:RegisterEffect(e4)

    aux.GlobalCheck(s,function()
        local ge=Effect.CreateEffect(c)
        ge:SetType(EFFECT_TYPE_FIELD)
        ge:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
        ge:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
        ge:SetTarget(function(e,cc) return cc:IsType(TYPE_SPELL) and c:IsOriginalCode(id) end)
        ge:SetOperation(s.AuxHandling)
        ge:SetValue(aux.TRUE())
        Duel.RegisterEffect(ge,0)

    end)
    end

function s.AuxHandling(e,tc,tp,sg)
    sg:RemoveCard(e:GetHandler())
end



function s.efilter(e,te)
	return (te:GetOwner()~=e:GetOwner()) and not te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end

