--World of Spirits - Under the Minus Curse
local s,id=GetID()
function s.initial_effect(c)
		local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    --"Earthbound Immortal" and Beast Synchro monsters you control gain 100 ATK for each non-Beast/Beast-Warrior/Winged Beast monster in your GY. 
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.atktarg)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    --If this card you control is destroyed: You can Special Summon 1 Monster from your GY or Banishment, ignoring its summoning Conditions, also until the end of the next turn, "Earthbound Immortal" monsters you control cannot be destroyed by card effects. 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_LEAVE_FIELD_P)
    e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_DESTROY) end)
    e4:SetOperation(s.protectearthboundsop)
    c:RegisterEffect(e4)
end
s.listed_series={SET_EARTHBOUND_IMMORTAL}

function s.thfilter(c)
	return c:IsMonster() and c:IsRace(RACE_BEAST)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.atktarg(e,c)
    return c:IsFaceup() and (c:IsSetCard(SET_EARTHBOUND_IMMORTAL) or (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_BEAST)))
end

function s.notbeastfilter(c)
    return c:IsMonster() and not c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINGEDBEAST)
end

function s.atkval(e,c)
    local g=Duel.GetMatchingGroup(s.notbeastfilter,c:GetControler(),LOCATION_GRAVE,0,nil)
    return g:GetCount()*100
end

function s.summonfilter(c,e,tp)
    return c:IsMonster() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.summonfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.summonfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
    end
end

function s.protectearthboundsop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_EARTHBOUND_IMMORTAL))
    e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
end