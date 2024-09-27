--Nimble Lemming
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetTarget(s.target2)
    e4:SetCountLimit(1,{id,1})
	e4:SetOperation(s.operation2)
	c:RegisterEffect(e4)
	
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp, LOCATION_MZONE)>0) and Duel.IsPlayerCanSpecialSummon(tp,SUMMON_TYPE_SPECIAL,POS_FACEUP,tp,e:GetHandler()) end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local token=Duel.CreateToken(tp, id)
    if not token:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false,POS_FACEUP) then return end
    Duel.SpecialSummon(token, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil, e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.filter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft = 1 end
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
    if #g>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,ft,nil)
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end

end