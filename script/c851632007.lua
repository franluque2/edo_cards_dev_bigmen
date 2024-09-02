--Dark Contract with the Dank Depths
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetHintTiming(0,TIMING_END_PHASE)
    e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
	e2:SetTarget(s.target2)
    e2:SetCondition(aux.exccon)
	e2:SetCost(aux.selfbanishcost)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)

end
s.listed_names={CARD_ABYSSAL_DREDGE}

function s.desfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_ABYSSAL_DREDGE) and c:IsDestructable()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if Duel.Destroy(sg,REASON_EFFECT) then
        Duel.BreakEffect()
        if Duel.Draw(tp, #sg, REASON_EFFECT) then
            Duel.BreakEffect()
            WbAux.SpecialSummonDredge(tp)
        end

    end
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp) end
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,0,#sg,0,0)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return #eg==1
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
		and tc:IsType(TYPE_EFFECT) end
    Duel.HintSelection(tc)
    e:GetHandler():SetCardTarget(tc)
    e:SetLabelObject(tc)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=e:GetLabelObject()
    if not tc then return end

    Debug.Message("HERE")
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e2:SetCondition(s.gspcon)
    e2:SetLabel(tc:GetOriginalCode())
	e2:SetOperation(s.gspop)
	c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
end


function s.addefffilter(c,tp)
	return c:IsFaceup() and c:IsCode(CARD_ABYSSAL_DREDGE) and c:IsSummonPlayer(tp)
end
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.addefffilter,1,nil,tp)
end

function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.addefffilter, nil, tp)
    local code=e:GetLabel()
    for tc in g:Iter() do
        tc:CopyEffect(code,RESET_EVENT|RESETS_STANDARD_DISABLE,1)
    end
end