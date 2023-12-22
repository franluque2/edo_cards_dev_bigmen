-- Chimera Hydradrive Draghead - Aqua
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,s.filtermats,5,5)
	c:EnableReviveLimit()
	--cannot special summon from Gy or banish
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--can only control 1 draghead
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,1577),LOCATION_MZONE)
	
	--return to extra in ep, if possible, summon back dragrid
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.EnableReturn)
	c:RegisterEffect(e2)

		--on special summon, negate all monsters on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
		if #g1>0 then
			Duel.BreakEffect()
		end
		local ng=g1:Filter(Card.IsNegatableMonster,nil)
		for nc in aux.Next(ng) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_PHASE+PHASE_END)
			nc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_PHASE+PHASE_END)
			nc:RegisterEffect(e2)
			if nc:IsType(TYPE_TRAPMONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_PHASE+PHASE_END)
				nc:RegisterEffect(e3)
			end
		end
end



function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end



function s.drag_filter(c,e,tp)
	return c:IsCode(81632008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0
end

function s.EnableReturn(e,tp,eg,ep,ev,re,r,rp)
	--return
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	if c:IsFacedown() then return end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if c:IsLocation(LOCATION_EXTRA) and Duel.IsExistingMatchingCard(s.drag_filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then
			local tg=Duel.GetFirstMatchingCard(s.drag_filter,tp,LOCATION_EXTRA,0,nil,e,tp)
			if tg then
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	c:RegisterEffect(e1)
end

function s.filtermats(c)
return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_LINK)
end
