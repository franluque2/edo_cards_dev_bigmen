--Dragon Ball Technique - Kamehameha
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetCost(s.cost)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e2:SetRange(LOCATION_HAND)
	c:RegisterEffect(e2)

end
s.listed_series={SET_DRAGON_BALL}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then return Duel.GetTurnPlayer()==tp or Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    local c=e:GetHandler()
    if Duel.GetTurnPlayer()~=tp then
        Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local num=Duel.GetFlagEffect(0, id)
    if chk==0 then return true end
    if num==0 then
        e:SetLabel(1)
        e:SetCategory(CATEGORY_DRAW)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    elseif num==1 then
        e:SetLabel(2)
    else
        e:SetLabel(3)
        e:SetCategory(CATEGORY_DESTROY)
        local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)    
    end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(SET_DRAGON_BALL)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local num=e:GetLabel()

    if num==1 then
        Card.CancelToGrave(c)
        Duel.RegisterFlagEffect(0,id,0,0,0)

        if Duel.SendtoHand(c, tp, REASON_EFFECT) and Duel.Draw(tp,1,REASON_EFFECT)>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e1:SetDescription(aux.Stringid(id,2))
            e1:SetTargetRange(1,0)
            e1:SetTarget(s.splimit)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    elseif num==2 then
        Card.CancelToGrave(c)

        local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
        Duel.RegisterFlagEffect(0,id,0,0,0)

        if Duel.SendtoHand(c, tp, REASON_EFFECT) and #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local sg=g:Select(tp,1,1,nil)
        Duel.HintSelection(sg)
        local tc=sg:GetFirst()
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e3:SetDescription(aux.Stringid(id,2))
        e3:SetTargetRange(1,0)
        e3:SetTarget(s.splimit)
        e3:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e3,tp)
        end
    else
        Duel.RegisterFlagEffect(0,id,0,0,0)
        local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
        Duel.Destroy(sg,REASON_EFFECT)
    
    end
end

function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end