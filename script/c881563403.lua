--Goku, Super Saiyan
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
    
    local e6=WbAux.CreateDBZInstantAttackEffect(c,id,SuperSaiyanGokuDestroyop)
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


end

function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end

function SuperSaiyanGokuDestroyop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end


s.listed_names={CARD_DRAGON_BALLS,id+1}
s.listed_series={SET_DRAGON_BALL}