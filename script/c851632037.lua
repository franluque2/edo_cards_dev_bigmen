--Neo Flamvell Magician
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(_,_c) return _c:IsAttribute(ATTRIBUTE_FIRE) end)
	e2:SetValue(500)
	c:RegisterEffect(e2)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LEAVE_GRAVE+CATEGORY_CONJURE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.gycon)
	e4:SetTarget(s.gytg)
	e4:SetOperation(s.gyop)
	c:RegisterEffect(e4)
	
end
s.listed_series={SET_FLAMVELL}

function s.gycfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and not c:IsPreviousControler(tp)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gycfilter,1,nil,tp)
end
function s.gyfilter(c,e,tp)
	return c:IsSetCard(SET_FLAMVELL) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp,false,false,POS_FACEUP)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) or
         (Duel.IsPlayerCanSpecialSummonMonster(tp, 68226653, SET_FLAMVELL, TYPE_EFFECT, 1100, 200, 2, RACE_PYRO, ATTRIBUTE_FIRE) and not Duel.IsPlayerAffectedByEffect(tp,CARD_NECROVALLEY) ) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_CONJURE,nil,1,tp,LOCATION_GRAVE)

end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local dragnov=Duel.CreateToken(tp, 68226653)
    if Duel.SendtoGrave(dragnov, REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local tc=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.gyfilter), tp, LOCATION_GRAVE, 0, 1,1,false,nil,e,tp)
        if tc then
            Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp,tp, false,false, POS_FACEUP)
        end
    end
end



function s.filter(c)
	return (c:IsSetCard(SET_FLAMVELL) or c:IsCode(74845897)) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_FIRE) end)
    Duel.RegisterEffect(e1,tp)

end