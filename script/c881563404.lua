--Vegeta, Saiyan Invader
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1, e11, e12=WbAux.CreateDBZPlaceDragonBallsEffect(c)
    c:RegisterEffect(e1)
    c:RegisterEffect(e11)
    c:RegisterEffect(e12)

    local e6=WbAux.CreateDBZInstantAttackEffect(c,id)
    c:RegisterEffect(e6)


    local e2=WbAux.CreateDBZEvolutionEffect(c,id+2,InvaderVegetaSummonOp)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(s.ivcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)

    local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e7:SetCode(EFFECT_SPSUMMON_PROC)
	e7:SetRange(LOCATION_HAND)
	e7:SetCondition(s.spcon)
	c:RegisterEffect(e7)
end

s.listed_names={CARD_DRAGON_BALLS,id+2}
s.listed_series={SET_DRAGON_BALL}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_SAIYAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(7)
end

function InvaderVegetaSummonOp(e,tp,eg,ep,ev,re,r,rp)
    if not (Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)) then return end
    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.ivcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end