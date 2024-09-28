--Gem-Knight Morions
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x47),2,2)
	local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x1047),matfilter=aux.FALSE,extrafil=s.extrafil, extratg=s.extratg}

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
    e1:SetCondition(function () return Duel.IsMainPhase() end)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.spcost)
    e1:SetCountLimit(1,id)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)


    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0x1047,0x47}


function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function s.spfilter(c)
    return c:IsAbleToGrave() and c:IsCanBeFusionMaterial() and c:IsType(TYPE_NORMAL) and not c:IsForbidden()
end

function s.extrafil(e,tp,mg1)
	return Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end


function s.fugemfilter(c)
	return c:IsSetCard(0x1047) and c:IsFaceup()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.fugemfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.fugemfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.IsExistingMatchingCard(Card.IsCanAttack, tp, 0, LOCATION_MZONE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.fugemfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        local g=Duel.GetMatchingGroup(Card.IsCanAttack, tp, 0, LOCATION_MZONE, nil)
        g=g:Filter(aux.NOT(Card.IsImmuneToEffect), nil, e)
        if #g>0 then
            local c=g:Select(tp, 1,1,nil):GetFirst()

            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1,0)
            e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
            Duel.RegisterEffect(e1,tp)

            Duel.CalculateDamage(c, tc)
    
        end


	end
end
