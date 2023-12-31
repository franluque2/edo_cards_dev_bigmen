-- Medidinal CanD
local s,id=GetID()
function s.initial_effect(c)
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetRange(LOCATION_ALL)
	e2:SetValue(20871001)
	c:RegisterEffect(e2)
end

function s.candfilter(c)
    return c:IsCode(160205053,160428037,160005039,160005040,160006041,160011054,160007035,160401006,160428027) 
        or c:IsOriginalCode(id)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
    Duel.SetTargetPlayer(tp)
    local heal=200+Duel.GetMatchingGroupCount(s.candfilter, tp, LOCATION_GRAVE, 0, nil)*100
    if c:GetFlagEffect(81633119)>0 then
        heal=heal+c:GetFlagEffectLabel(81633119)
    end
	Duel.SetTargetParam(heal)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,heal)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
