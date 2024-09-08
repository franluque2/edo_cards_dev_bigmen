--Metamorphic Cycle
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ABYSSAL_DREDGE}


function s.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE) and c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return WbAux.CanPlayerSummonDredge(tp) end
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#sg+1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if sg and #sg>0 then
		
	
	if Duel.Destroy(sg,REASON_EFFECT) then
        if not (not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and WbAux.CanPlayerSummonDredge(tp)) then return end
        Duel.BreakEffect()

        for i = 1, #sg+1, 1 do
            local dredge=Duel.CreateToken(tp, CARD_ABYSSAL_DREDGE)
            Duel.SpecialSummonStep(dredge, SUMMON_TYPE_SPECIAL, tp, tp, false,false,POS_FACEUP)
        end
        Duel.SpecialSummonComplete()
    end
	else
	WbAux.SpecialSummonDredge(tp)
	end
end

