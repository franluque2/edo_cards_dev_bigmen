--Kirei the Fated Master
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    -- You cannot Special Summon monsters, except Spirit monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsType(TYPE_SPIRIT) end)
	c:RegisterEffect(e1)

    -- If this card is Normal or Special Summoned from the hand: You can Special Summon 1 DARK Warrior "Fated" Spirit monster from your Hand or Deck.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,0})
    e2:SetTarget(s.sptarget)
    e2:SetCondition(s.spcon)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    --Your opponent must also discard a Monster Card to activate "Dregs of Angra Mainju".
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ACTIVATE_COST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetCost(s.costchk)
	e4:SetTarget(s.costtg)
	e4:SetOperation(s.costop)
	c:RegisterEffect(e4)

    --If this card leaves the field: You can add 1 "Dregs of Angra Mainju" from Outside the Duel to your opponent's hand, and if you do, Special Summon this card. 
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_LEAVE_FIELD)
    e5:SetCondition(s.spgravecon)
    e5:SetTarget(s.spgravetg)
    e5:SetOperation(s.spgraveop)
    c:RegisterEffect(e5)

    WbAux.StartDeadServantFilter()
end
s.listed_names={CARD_DREGS_ANGRA_MAINYU}
s.listed_series={SET_FATED}

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_FATED) and c:IsType(TYPE_SPIRIT) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.discardfilter(c)
    return c:IsMonster() and c:IsDiscardable(REASON_COST)
end

function s.costchk(e,te_or_c,tp)
	return Duel.IsExistingMatchingCard(s.discardfilter,tp,0,LOCATION_HAND,1,nil)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local g=Duel.SelectMatchingCard(tp,s.discardfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end


function s.costtg(e,te,tp)
	if not te:IsActivated() then return false end
	local tc=te:GetHandler()
    if tc:IsCode(CARD_DREGS_ANGRA_MAINYU) then return true
	else return false end
end


function s.spgravecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp, id)<=WbAux.GetDifferentDeadServantCodes()
end

function s.spgravetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 1)
end

function s.spgraveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    WbAux.AddDregs(1-tp,1)
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end