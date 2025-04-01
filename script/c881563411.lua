--Piccolo, Namekian Warrior
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    local e1, e11, e12=WbAux.CreateDBZPlaceDragonBallsEffect(c)
    c:RegisterEffect(e1)
    c:RegisterEffect(e11)
    c:RegisterEffect(e12)


    local e01=Effect.CreateEffect(c)
	e01:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e01:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e01:SetProperty(EFFECT_FLAG_DELAY)
	e01:SetCode(EVENT_TO_HAND)
	e01:SetCountLimit(1,id)
	e01:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e01:SetTarget(s.sptg)
	e01:SetOperation(s.spop)
	c:RegisterEffect(e01)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(function(e,c) return c:IsCode(CARD_DRAGON_BALLS) end)
	e3:SetValue(1)
	c:RegisterEffect(e3)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(aux.SelfTributeCost)
	e2:SetTarget(s.dsptg)
	e2:SetOperation(s.dspop)
	c:RegisterEffect(e2)

    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)

    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_DRAGON_BALL}
s.listed_names={CARD_DRAGON_BALLS}


function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp, id+1)>0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a or d then
		Duel.RegisterFlagEffect(0,id+1,RESET_PHASE+PHASE_END,0,1)
	end
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.dspfilter(c,e,tp)
	return c:IsSetCard(SET_DRAGON_BALL) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.dspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.dspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end