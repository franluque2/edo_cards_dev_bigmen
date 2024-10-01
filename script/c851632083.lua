--Gem-Knight Tremolite
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
		-- Special Summon itself from the hand
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,0))
        e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
        e1:SetProperty(EFFECT_FLAG_DELAY)
        e1:SetCode(EVENT_TO_HAND)
        e1:SetCountLimit(1,id)
        e1:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
        e1:SetTarget(s.sptg)
        e1:SetOperation(s.spop)
        c:RegisterEffect(e1)
        -- Search 1 "Gem Knight" Normal or GK Fusion
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(id,1))
        e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
        e2:SetProperty(EFFECT_FLAG_DELAY)
        e2:SetCode(EVENT_SUMMON_SUCCESS)
        e2:SetCountLimit(1,{id,1})
        e2:SetTarget(s.thtg)
        e2:SetOperation(s.thop)
        c:RegisterEffect(e2)
        local e3=e2:Clone()
        e3:SetCode(EVENT_SPSUMMON_SUCCESS)
        c:RegisterEffect(e3)

        local e4=Effect.CreateEffect(c)
        e4:SetDescription(aux.Stringid(id,2))
        e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
        e4:SetProperty(EFFECT_FLAG_DELAY)
        e4:SetCode(EVENT_TO_GRAVE)
        e4:SetCountLimit(1,{id,2})
        e4:SetCondition(s.summcon)
        e4:SetTarget(s.summtg)
        e4:SetOperation(s.summop)
        c:RegisterEffect(e4)

        Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

end

s.listed_series={0x1047}
s.listed_names={1264319}

local normalgks={76908448,91731841,54620698,27126980,99645428}

function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x1047)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)

    aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)

end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thfilter(c)
	return ((c:IsSetCard(0x1047) and c:IsMonster() and c:IsType(TYPE_NORMAL)) or c:IsCode(1264319)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)

    aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)

end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x1047) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalSetCard(0x1047)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end


function s.summcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end

function s.summtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)

    aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
function s.summop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    local res=Duel.SelectCardsFromCodes(tp,1,1,false,false,normalgks)

    local newcard=Duel.CreateToken(tp, res)

    Duel.SendtoGrave(newcard,REASON_RULE+REASON_RETURN)


    Duel.SendtoDeck(c, tp, -2, REASON_RULE)
end