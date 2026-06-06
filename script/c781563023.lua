--Marked by the Lizard
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)


    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil, nil, nil, true, nil)
    c:RegisterEffect(e1)
    c:RegisterEffect(e2)
end


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end


function s.ccarayhuafilter(c)
    return c:IsCode(79798060) and c:GetFlagEffect(id)==0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetCondition(function() return Duel.IsExistingMatchingCard(s.ccarayhuafilter, tp, LOCATION_ALL, 0, 1, nil) end)
    e1:SetOperation(s.rewriteccarayhua)
    Duel.RegisterEffect(e1,tp)
end

function s.rewriteccarayhua(e,tp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.ccarayhuafilter, tp, LOCATION_ALL, 0, nil)
    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, 0,0,0)

        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(id,0))
        e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetRange(LOCATION_HAND)
        e2:SetCountLimit(1,{id,0})
        e2:SetCost(Cost.SelfReveal)
        e2:SetTarget(s.sptg)
        e2:SetOperation(s.spop)
        tc:RegisterEffect(e2)


        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(id,0))
        e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e2:SetRange(LOCATION_GRAVE)
        e2:SetCountLimit(1,{id,1})
        e2:SetTarget(s.sptg2)
        e2:SetOperation(s.spop2)
        tc:RegisterEffect(e2)
    end
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_REPTILIANNE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 

        local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and g:GetClassCount(Card.GetCode)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetLocationCount(tp,LOCATION_MZONE)<=0) or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0) then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g>=2 and g:GetClassCount(Card.GetCode)>=2 then

		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
        if #sg>0 then
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
            local sc1=sg:Select(tp, 1, 1, nil):GetFirst()
            local sc2=sg:RemoveCard(sc1):GetFirst()

            Duel.SpecialSummonStep(sc1, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP_DEFENSE)
            Duel.SpecialSummonStep(sc2, SUMMON_TYPE_SPECIAL, tp, 1-tp, false, false, POS_FACEUP_DEFENSE)
            Duel.SpecialSummonComplete()
        end
        Duel.BreakEffect()
        Duel.SendtoGrave(e:GetHandler(), REASON_DISCARD+REASON_EFFECT)
end
end


function s.shufflefilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_REPTILE) and c:IsAbleToDeckAsCost()
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc~=c and s.shufflefilter(chkc) end
	if chk==0 then return ((Duel.GetLocationCount(tp,LOCATION_MZONE,0)>=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 )
		and Duel.IsExistingTarget(s.shufflefilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.shufflefilter,tp,LOCATION_GRAVE,0,1,1,c)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE,0)>=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    if not (b1 or b2) then return end

    Duel.SendtoDeck(tc, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)

    local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
                                {b2, aux.Stringid(id,2)})
    if op==1 then
        --Special Summon this card, but its effects are negated, also banish it when it leaves the field
        if c:IsRelateToEffect(e) then


            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
            c:RegisterEffect(e1,true)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
            c:RegisterEffect(e2,true)

            local e3=Effect.CreateEffect(c)
            e3:SetDescription(3300)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e3:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
            e3:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e3,true)

            local e4=Effect.CreateEffect(c)
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e4:SetRange(LOCATION_MZONE)
            e4:SetValue(function (_,_te,_,_c) return _te:GetOwner()==_c end)
            e4:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
            c:RegisterEffect(e4,true)

            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)

        end
    else
        --place this face-up as a continuous spell, but banish it when it leaves the field

        if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3300)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1,true)
        end

    end

end