--Son Goku, Saiyan
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1, e11, e12=WbAux.CreateDBZPlaceDragonBallsEffect(c)
    c:RegisterEffect(e1)
    c:RegisterEffect(e11)
    c:RegisterEffect(e12)

    local e2=WbAux.CreateDBZEvolutionEffect(c,id+1)
    c:RegisterEffect(e2)

    local e6=WbAux.CreateDBZInstantAttackEffect(c,id)
    e6:SetCondition(s.con)
    c:RegisterEffect(e6)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(s.ivcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)

    local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,0))
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetType(EFFECT_TYPE_QUICK_O)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetRange(LOCATION_HAND)
	e9:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e9:SetCountLimit(1,id)
	e9:SetCondition(function(e,tp) return Duel.IsMainPhase() and Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0 end)
	e9:SetTarget(s.sptg)
	e9:SetOperation(s.spop)
	c:RegisterEffect(e9)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)



	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e8:SetValue(1)
	c:RegisterEffect(e8)


end
s.listed_names={CARD_DRAGON_BALLS,id+1}
s.listed_series={SET_DRAGON_BALL}

function s.con(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tn=Duel.GetTurnPlayer()
    return ((tn==tp and Duel.IsMainPhase()) or (tn~=tp and Duel.IsBattlePhase())) and (c:GetFlagEffect(id)==0 or Duel.GetChainInfo(0, CHAININFO_CHAIN_COUNT)>2)
end

function s.chainfilter(re,tp,cid)
	return not (re:IsMonsterEffect() and re:GetActivateLocation()&(LOCATION_MZONE)>0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        c:RegisterFlagEffect(id, RESETS_STANDARD+RESET_PHASE+PHASE_END, 0, 0)
	end
end

function s.ivcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end