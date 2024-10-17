--Paleozoic Haplophrentis
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,nil,2,2,s.lcheck)
	--Unaffected by monsters' effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.gainop)
	c:RegisterEffect(e2)



	--Copy the activation effect of a Normal Trap from your GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetCost(s.gycost)
	e3:SetTarget(s.gytg)
    e3:SetOperation(s.operation)
    e3:SetCountLimit(1,id)
	e3:SetHintTiming(TIMING_DRAW_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3)



end

s.listed_series={SET_PALEOZOIC}

local STRING_MAP={}
STRING_MAP[1154611]=1
STRING_MAP[2376209]=2
STRING_MAP[24903843]=3
STRING_MAP[35035481]=4
STRING_MAP[38761908]=5
STRING_MAP[61420130]=6
STRING_MAP[64765016]=7
STRING_MAP[98414735]=8

function s.efilter(e,re)
	return re:IsMonsterEffect() and re:GetOwner()~=e:GetOwner()
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_PALEOZOIC,lc,sumtype,tp)
end

function s.paleotrapfilter(c)
    return c:IsSetCard(SET_PALEOZOIC) and c:IsOriginalType(TYPE_TRAP)
end

function s.gainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_LINK) then return end

    local mats=c:GetMaterial()
    local g=mats:Filter(s.paleotrapfilter, nil)
    for tc in g:Iter() do
        local te=tc:GetActivateEffect()

        if te then
            local e1=Effect.CreateEffect(c)
            if STRING_MAP[tc:GetOriginalCode()] then
                e1:SetDescription(aux.Stringid(id, STRING_MAP[tc:GetOriginalCode()]))
            end
            e1:SetType(EFFECT_TYPE_IGNITION)
            e1:SetRange(LOCATION_MZONE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
            if te:GetProperty() then
                e1:SetProperty(te:GetProperty())
            end
            if te:GetCondition() then
                e1:SetCondition(te:GetCondition())
            end
            if te:GetTarget() then
                e1:SetTarget(te:GetTarget())
            end
            if te:GetOperation() then
                e1:SetOperation(te:GetOperation())
            end
            if te:GetCost() then
                e1:SetCost(te:GetCost())
            end
            c:RegisterEffect(e1)
        end
    end
end



function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te or not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,c) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,c)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end

function s.tgfilter(c)
	return c:IsNormalTrap() and not c:IsCode(id) and c:CheckActivateEffect(false,true,false)~=nil
end