--IPC Grunt: Field Personnel
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.confunc)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.confunc(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLocationCount(tp, LOCATION_MZONE) and Duel.IsPlayerCanSpecialSummonMonster(tp, id, SET_IPC, TYPE_MONSTER+TYPE_EFFECT, 1400, 2000, 4, RACE_WARRIOR, ATTRIBUTE_LIGHT)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	
    local num=Duel.GetLocationCount(tp, LOCATION_MZONE)
    if num==0 then return end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then num=1 end
	for i=1,num do
		local token=Duel.CreateToken(tp, id)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(id, 1))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not (c:IsSetCard(SET_IPC) or c:IsType(TYPE_TOKEN)) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

