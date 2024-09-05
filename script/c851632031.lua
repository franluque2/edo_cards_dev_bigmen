--Payak, Spiderite Queen
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),1,2)
	c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_CONJURE)
	e1:SetCode(EVENT_PHASE+PHASE_DRAW)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.bancon)
    e1:SetCost(s.bancost)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.dxmcostgen(1,1,nil))
    e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.diszacon)
	e2:SetOperation(s.diszaop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)

    --Special Summon "Spideriteling" monsters from the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e) return e:GetLabel()>0 and e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Save how many materials it had before leaving the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(function(e) e:GetLabelObject():SetLabel(e:GetHandler():GetOverlayCount()) end)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)

end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}


function s.spfilter(c,e,tp)
	return c:IsCode(CARD_SPIDERITELING) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local mat_ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),mat_ct)
	if ft==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end


function s.diszafilter(c)
	return c:IsFaceup() and c:IsNegatable()
end

function s.diszacon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(s.diszafilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and
        Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_REMOVED, LOCATION_REMOVED, 1, nil, CARD_SPIDERITELING)
end
function s.diszaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)

    if Duel.SendtoGrave(tg,REASON_EFFECT+REASON_RETURN)>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local g=Duel.SelectMatchingCard(tp,s.diszafilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        Duel.HintSelection(g)
        local tc=g:GetFirst()
        if tc then
            tc:NegateEffects(c)
        end
    
    end

end


function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsPlayerCanSendtoGrave(tp, e:GetHandler())
end
function s.bancost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Card.IsPublic(e:GetHandler()) end
	Duel.ConfirmCards(1-tp, e:GetHandler())
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
    local Spideriteling=WbAux.GetSpideriteling(tp)
    Duel.SendtoGrave(Spideriteling, REASON_EFFECT)

end