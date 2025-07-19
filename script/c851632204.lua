--Clear Duston
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --cannot be used as Synchro, Xyz, Fusion or Link Material
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    e1:SetRange(LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(e2)

    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    c:RegisterEffect(e3)

    local e4=e1:Clone()
    e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(e4)


    	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_UNRELEASABLE_SUM)
	e6:SetValue(s.sumval)
	c:RegisterEffect(e6)

    --During the Main Phase: You can Discard 1 Card; special Summon this card from your hand in defense position to either field
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,0))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetRange(LOCATION_HAND)
    e7:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
    e7:SetCountLimit(1,{id,0})
    e7:SetCost(s.spcost)
    e7:SetTarget(s.sptg)
    e7:SetOperation(s.spop)
    c:RegisterEffect(e7)

    --while you control this card that is not in its owners possession, you receive all the effects of clear world
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e8:SetCode(EFFECT_CLEAR_WALL)
    e8:SetRange(LOCATION_MZONE)
    e8:SetTargetRange(0,1)
	e8:SetCondition(s.clearwallcon)
	c:RegisterEffect(e8)

    local e9=Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id,1))
    e9:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e9:SetCode(EVENT_SPSUMMON_SUCCESS)
    e9:SetCountLimit(1,{id,1})
    e9:SetTarget(s.thtg)
    c:RegisterEffect(e9)
end
s.listed_names={CARD_CLEAR_WORLD}
s.listed_series={SET_DUSTON}

function s.sumval(e,c)
	return not c:ListsCode(CARD_CLEAR_WORLD)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD, e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp))
        or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp)
    local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
    if not (b1 or b2) then return end
    local op=Duel.SelectEffect(tp,
        {b1,aux.Stringid(id,1)},
        {b2,aux.Stringid(id,2)})
    local target_player=op==1 and tp or 1-tp
    Duel.SpecialSummon(c,0,tp,target_player,false,false,POS_FACEUP_DEFENSE)

end

function s.clearwallcon(e)
    return not e:GetHandler():IsControler(e:GetHandler():GetOwner())
end



function s.thfilter(c)
    return (c:IsCode(CARD_CLEAR_WORLD) or c:IsSetCard(SET_DUSTON) or c:ListsCode(CARD_CLEAR_WORLD)) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    local b2=true
    local op=Duel.SelectEffect(tp,
        {b1,aux.Stringid(id,3)},
        {b2,aux.Stringid(id,4)})

    if op==1 then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
        e:SetOperation(s.thop1)
    else
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,1-tp,LOCATION_DECK|LOCATION_GRAVE)
        e:SetOperation(s.thop2)
    end
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.thfilter,1-tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) then return end
    local tg=Duel.GetMatchingGroup(s.thfilter,1-tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
    local g=aux.SelectUnselectGroup(tg,e,1-tp,0,3,s.check,1,tp,HINTMSG_ATOHAND)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(tp,g)
    end
end

function s.check(g)
    return g:FilterCount(Card.IsCode,nil,CARD_CLEAR_WORLD)<=1
        and g:FilterCount(Card.IsSetCard,nil,SET_DUSTON)<=1
        and g:FilterCount(Card.ListsCode,nil,CARD_CLEAR_WORLD)<=1
end