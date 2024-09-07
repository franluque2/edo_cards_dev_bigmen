--Spiderite Nursery
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetValue(aux.indoval)
    e2:SetTarget(function (_e,_c) return _c:IsFaceup() and _c:IsSetCard(SET_SPIDERITE) and not _c==_e:GetHandler() end)
    e2:SetCondition(function (_e) return Duel.IsExistingMatchingCard(Card.IsCode, _e:GetHandlerPlayer(), LOCATION_GRAVE, 0, 5, nil, CARD_SPIDERITELING) end)
	c:RegisterEffect(e2)


    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetCountLimit(1)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTarget(s.tarfunc)
    e3:SetCost(s.costfunc)
    e3:SetOperation(s.opfunc)
    c:RegisterEffect(e3)

	
end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}

function s.spcostfilter(c,e,tp)
	return c:IsCode(CARD_SPIDERITELING) and c:IsMonster() and not c:IsPublic() and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false,false)
end

function s.costfunc(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
         return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	Duel.SetTargetCard(rc)
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
end
function s.tarfunc(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
         return Duel.GetLocationCount(tp,LOCATION_MZONE) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.adfunc(c)
    return c:IsSetCard(SET_SPIDERITE) and c:IsAbleToHand()
end
function s.opfunc(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local rc=Duel.GetFirstTarget()

	if not rc:IsRelateToEffect(e) or Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if Duel.IsExistingMatchingCard(s.adfunc, tp, LOCATION_GRAVE, 0, 1, nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.adfunc,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
        end
end