--Halginoth, the Endless
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),4,2,nil,nil,7)
	c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, {id,0})
	e1:SetTarget(s.sptg)
    e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

    --Special Summon itself from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)

end
s.listed_names={CARD_ABYSSAL_DREDGE}

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return WbAux.CanPlayerSummonDredge(tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if WbAux.CanPlayerSummonDredge(tp) then
		WbAux.SpecialSummonDredge(tp)
	end
end


function s.matfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_ABYSSAL_DREDGE)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.matfilter, tp, LOCATION_ONFIELD, 0, 1, nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local tc=Duel.SelectMatchingCard(tp, s.matfilter, tp, LOCATION_ONFIELD, 0, 1,1,false,nil):GetFirst()
		if s.matfilter(tc) and not tc:IsImmuneToEffect(e) then
		    Duel.Overlay(c,tc,true)
    end
	end
end
