--Everdark Dragon Quilla
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()

    local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.synclimit)
	c:RegisterEffect(e0)


    	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)


    --Register if it's Special Summoned with "Harmonic Synchro Fusion" or an "Earthbound" card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)



    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e4:SetValue(s.condition)
	c:RegisterEffect(e4)


    --If a level 6 or higher "Earthbound" monster you control is destroyed while this card is in your GY: You can target 1 monster your opponent controls; Special Summon this card, and if you do, destroy that target, then gain LP equal to the destroyed monster's ATK.
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_RECOVER)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1,{id,1})
    e5:SetCondition(s.spcon)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)

end
s.listed_names={78552773, 7473735} --Supay, Harmonic Synchro Fusion
s.listed_series={SET_EARTHBOUND}

function s.tunerfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_EARTHBOUND,scard,sumtype,tp) or c:IsCode(78552773)
end

function s.synclimit(e,se,sp,st)
    if (st&SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO then return true end
	if (st&SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL and se then
		return se:GetHandler():IsSetCard(SET_EARTHBOUND) or se:GetHandler():IsCode(7473735)
	end
	return false
end


function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(7473735) or re:GetHandler():IsSetCard(SET_EARTHBOUND) then
        e:GetHandler():CompleteProcedure()
	end
end


function s.thfilter(c)
	return c:IsSetCard(SET_EARTHBOUND) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.condition(e,c)
	return c:IsSetCard(SET_EARTHBOUND_IMMORTAL)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.tdcfilter,1,nil,tp) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.tdcfilter(c,tp)
    return c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(SET_EARTHBOUND) and c:IsLevelAbove(6) and c:IsControler(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,1-tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0) then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Destroy(tc,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.Recover(tp,tc:GetPreviousAttackOnField(),REASON_EFFECT)
    end
end