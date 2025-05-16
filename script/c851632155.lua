--Metamorphic Sacrifice
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK) or (c:IsCode(CARD_ABYSSAL_DREDGE) or c:ListsCode(CARD_ABYSSAL_DREDGE)) end)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.discon)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)

end
s.listed_names={CARD_ABYSSAL_DREDGE}

function s.cfilter(c)
	return c:IsReleasable()
end

function s.tdfilter(c,tp)
	return c:IsControler(tp)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.tdfilter, nil,tp)>0
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #rg>1 and Duel.IsExistingTarget(Card.IsReleasable, tp, LOCATION_MZONE, 0, 1, nil) end
    local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE,s.rescon)
	Duel.Release(g,REASON_COST)
end

function s.spfileter(c,e,tp)
    return (c:IsCode(CARD_ABYSSAL_DREDGE) or c:ListsCode(CARD_ABYSSAL_DREDGE)) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		return ft>-1 and Duel.IsExistingMatchingCard(s.spfileter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK) and not (c:IsCode(CARD_ABYSSAL_DREDGE) or c:ListsCode(CARD_ABYSSAL_DREDGE)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfileter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end


function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tgfilter,1,nil,tp) and #tg==1 and WbAux.CanPlayerSummonDredge(tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK) and not (c:IsCode(CARD_ABYSSAL_DREDGE) or c:ListsCode(CARD_ABYSSAL_DREDGE)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    if not WbAux.CanPlayerSummonDredge(tp) then return end
    local tc=Duel.CreateToken(tp, CARD_ABYSSAL_DREDGE)
    Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
	if Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) then
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end