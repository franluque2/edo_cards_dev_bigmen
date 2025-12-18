--Subterror Behemoth Stalagticar
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
    e1:SetCode(EVENT_FLIP)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.drtg)
    e1:SetOperation(s.drop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function(e) return Duel.GetMatchingGroupCount(Card.IsFaceup, e:GetHandlerPlayer(), LOCATION_MZONE, 0, nil) == 0 end)
    e2:SetTarget(s.sptarget)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)

end
s.listed_series={SET_SUBTERROR_BEHEMOTH}

function s.tdfilter(c)
    return c:IsSetCard(SET_SUBTERROR_BEHEMOTH) and c:IsMonster() and (c:IsLocation(LOCATION_MZONE) or (c:IsLocation(LOCATION_HAND) and not c:IsPublic())) and c:IsAbleToDeck()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,e:GetHandler()) and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,99,e:GetHandler())
    if #g==0 then return end
    Duel.ConfirmCards(1-tp, g)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
    if ct==0 then return end
    if Duel.Draw(tp,ct+1,REASON_EFFECT)==0 then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then return end
    if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE)
        end
    end
end

function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetDescription(aux.Stringid(id,3))
    e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e0:SetTargetRange(1,0)
    e0:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_EARTH) end)
    e0:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e0,tp)

    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
        Duel.ConfirmCards(1-tp,c)

        if Duel.GetFieldGroupCount(1-tp, LOCATION_MZONE, 0)>0 then
            Duel.BreakEffect()
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
            e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e2:SetCode(EVENT_ADJUST)
            e2:SetCountLimit(1)
            e2:SetReset(RESET_PHASE|PHASE_END)
            e2:SetLabelObject(c)
            e2:SetCondition(function () return Duel.GetCurrentChain()==0 end)
            e2:SetOperation(s.setstatuschange)
            Duel.RegisterEffect(e2,tp)
        end
        Duel.SpecialSummonComplete()
    end
end

function s.setstatuschange(e,tp,eg,ev,ep,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and Duel.GetTurnPlayer()==tp then
		tc:SetStatus(STATUS_SUMMON_TURN, false)
        tc:SetStatus(STATUS_SPSUMMON_TURN, false)
	end
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD_PHASE_END&~RESET_TURN_SET),0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end