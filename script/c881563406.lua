--Vegeta, Super Saiyan
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableUnsummonable()
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)


	local e1, e11, e12=WbAux.CreateDBZPlaceDragonBallsEffect(c)
    c:RegisterEffect(e1)
    c:RegisterEffect(e11)
    c:RegisterEffect(e12)

    local e6=WbAux.CreateDBZInstantAttackEffect(c,id)
    c:RegisterEffect(e6)


    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)

	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e8:SetValue(1)
	c:RegisterEffect(e8)


    local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCode(EVENT_BATTLE_DESTROYING)
	e9:SetCondition(aux.bdocon)
	e9:SetTarget(s.target)
    e9:SetCountLimit(1,{id,2})
	e9:SetOperation(s.operation)
	c:RegisterEffect(e9)
end

s.listed_names={CARD_DRAGON_BALLS}
s.listed_series={SET_DRAGON_BALL}

function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end

function s.filter(c,e,tp)
	return c:IsSetCard(SET_DRAGON_BALL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end


s.listed_names={CARD_DRAGON_BALLS}
s.listed_series={SET_DRAGON_BALL}
