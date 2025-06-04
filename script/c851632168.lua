--Ere-Wight the Withered Monarch
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Becomes Skull Servant in GY
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(CARD_SKULL_SERVANT)
	c:RegisterEffect(e0)

    --Normal Summon from GY
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_names={CARD_SKULL_SERVANT}

function s.releasefilter(c, tp)
    return c:IsReleasable() and (c:IsControler(tp) or c:IsHasEffect(EFFECT_EXTRA_RELEASE_SUM))
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local min,max=e:GetHandler():GetTributeRequirement()
	if chk==0 then return e:GetHandler():IsSummonable(false,nil) and not Duel.IsPlayerAffectedByEffect(tp, EFFECT_NECRO_VALLEY)
        and Duel.IsExistingMatchingCard(s.releasefilter, tp, LOCATION_MZONE, LOCATION_MZONE, min, nil,tp) end
	Duel.SetOperationInfo(0, CATEGORY_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, e:GetHandler(), 1, 0, 0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local min,max=e:GetHandler():GetTributeRequirement()
    if not (aux.NecroValleyFilter(Card.IsSummonable,e:GetHandler(), false, nil, min) and Duel.IsExistingMatchingCard(s.releasefilter, tp, LOCATION_MZONE, LOCATION_MZONE, min, nil,tp)) then return end
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Summon(tp,e:GetHandler(),false,nil)
end