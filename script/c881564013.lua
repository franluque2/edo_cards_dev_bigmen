--Gilgamesh the Fated Artifact King
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)
	local sme,soe=Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP,EVENT_SPSUMMON_SUCCESS)
	sme:SetOperation(s.mretop)
	soe:SetOperation(s.mretop)

    -- For this card's Tribute Summon, you can also use equip spells in your hand as tribute.
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_EQUIP))
	e2:SetValue(POS_FACEUP)
	c:RegisterEffect(e2)

    --You cannot control other monsters, except DARK "Fated" monsters.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.adjustop)
	c:RegisterEffect(e3)
	--cannot summon,spsummon,flipsummon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.sumlimit)
	e4:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e6)
	--Cannot activate a monster's effect that flips itself face-up as cost if it's of a different Attribute than the other face-up monsters that player controls
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCode(EFFECT_CANNOT_ACTIVATE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(1,0)
	e7:SetValue(function(e,re,tp) return re:HasSelfChangePositionCost() and s[tp]>0 and re:GetHandler():IsAttributeExcept(s[tp]) end)
	c:RegisterEffect(e7)
    

    -- If this card is Normal or Special Summoned: you can equip 3 Equip Spells from your Deck or GY to this card
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,0))
    e8:SetCategory(CATEGORY_EQUIP)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e8:SetCode(EVENT_SUMMON_SUCCESS)
    e8:SetProperty(EFFECT_FLAG_DELAY)
    e8:SetTarget(s.eqtg)
    e8:SetOperation(s.eqop)
    c:RegisterEffect(e8)
    local e9=e8:Clone()
    e9:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e9)

    -- If this card leaves the field by an opponent's card while they have a Spell Card in hand: You can look at your opponent's hand and discard 1 card from it, and if you do, Special Summon this card. 
    local e10=Effect.CreateEffect(c)
    e10:SetDescription(aux.Stringid(id,1))
    e10:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
    e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e10:SetCode(EVENT_LEAVE_FIELD)
    e10:SetProperty(EFFECT_FLAG_DELAY)
    e10:SetCondition(s.retcon)
    e10:SetTarget(s.rettg)
    e10:SetOperation(s.retop)
    c:RegisterEffect(e10)
end
s.listed_series={SET_FATED}

function s.splimit(e,se,sp,st)
    return se:GetHandler():IsSetCard(SET_FATED)
end

function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local at=ATTRIBUTE_DARK
	if at==0 then return false end
	return (c:GetAttribute()~=at) or not c:IsSetCard(SET_FATED)
end
function s.rmfilter(c)
	return c:GetAttribute()==ATTRIBUTE_DARK
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,e:GetHandler())
	local c=e:GetHandler()
    g1:Remove(s.rmfilter,nil)
	local readjust=false
	if #g1>0 then
		Duel.SendtoGrave(g1,REASON_RULE,PLAYER_NONE,tp)
		readjust=true
	end
	if readjust then Duel.Readjust() end
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>2
        and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,3,nil,tp,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,3,0,0)
end

function s.eqfilter(c,tp,ec)
    return c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(ec)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=2 then return end
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp,c)
    if #g<3 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local sg=g:Select(tp,3,3,nil)
    for tc in sg:Iter() do
        if c:IsFaceup() and c:IsRelateToEffect(e) and tc:CheckUniqueOnField(tp) and tc:CheckEquipTarget(c) then
            Duel.Equip(tp,tc,c,true)
        end
    end
    if Duel.GetFlagEffect(0, id)==0 then
        Duel.BreakEffect()
        Duel.RegisterFlagEffect(0, id, RESET_PHASE+PHASE_END, 0, 1)
        WbAux.AddDregs(1-tp,2)
        local dregs1=Duel.CreateToken(1-tp, CARD_DREGS_ANGRA_MAINYU)
        local dregs2=Duel.CreateToken(1-tp, CARD_DREGS_ANGRA_MAINYU)
        local g1=Group.FromCards(dregs1,dregs2)
        Duel.SendtoDeck(g1, 1-tp, SEQ_DECKTOP, REASON_EFFECT)

    end
end



function s.mretop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then return Spirit.ReturnOperation(e,tp,eg,ep,ev,re,r,rp) end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return rp==1-tp and Duel.IsExistingMatchingCard(Card.IsType,1-tp,LOCATION_HAND,0,1,nil,TYPE_SPELL)
end

function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_HANDES, 0, 0, 1-tp, 1)
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetFieldGroupCount(1-tp, LOCATION_HAND, 0)==0 then return end
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
    local g=Duel.SelectMatchingCard(tp, aux.TRUE, 1-tp, LOCATION_HAND, 0, 1,1,nil)
    if #g>0 and Duel.SendtoGrave(g, REASON_EFFECT+REASON_DISCARD)>0 then
        if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 then
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end