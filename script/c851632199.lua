--Old Earthbound Prisoner Phaqcha
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    	--lv change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,0})
    e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)


    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,2})
    e4:SetCondition(s.adcon1)
    e4:SetTarget(s.adtg)
    e4:SetOperation(s.adop)
    c:RegisterEffect(e4)

    local e5=e4:Clone()
    e5:SetCode(EVENT_BE_MATERIAL)
    e5:SetCondition(s.adcon2)
    c:RegisterEffect(e5)
end
s.listed_names={7473735,78552773,78275321} -- Harmonic Synchro Fusion, Supay, Fire Ant Ascator
function s.counterfilter(c)
	return not (c:IsSummonLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION|TYPE_SYNCHRO))
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lv=e:GetHandler():GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	e:SetLabel(Duel.AnnounceLevel(tp,1,6,lv))
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

function s.thfilter(c)
	return c:IsCode(7473735) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)

    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION|TYPE_SYNCHRO) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalType(TYPE_FUSION|TYPE_SYNCHRO) end)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end




function s.adcon1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE)==7473735) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

function s.adcon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD) and r==REASON_SYNCHRO and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.adop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c, 0, tp, tp, false, false, POS_FACEUP) then
        
        local code=Duel.SelectCardsFromCodes(1-tp,1,1,false,false,{78552773,78275321})

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_CHANGE_CODE)
        e2:SetValue(code)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        c:RegisterEffect(e2)


        local e3=Effect.CreateEffect(c)
		e3:SetDescription(3300)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)

        local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_ADD_TYPE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetValue(TYPE_TUNER)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e4)
    end
    Duel.SpecialSummonComplete()
end