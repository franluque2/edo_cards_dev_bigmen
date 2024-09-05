--Spiderite Caretaker
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_SPIDERITELING}
s.listed_series={SET_SPIDERITE}

function s.filter(c,e,tp)
	return c:IsCode(CARD_SPIDERITELING) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end

function s.adfilter(c)
    return c:IsSetCard(SET_SPIDERITE) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.adfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local tc2=Duel.SelectMatchingCard(tp, s.adfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
            if #tc2>0 then
                Duel.SendtoHand(tc2, tp, REASON_EFFECT)
                Duel.ConfirmCards(1-tp, tc2)
            end

        end
	end
end


function s.tgfilter(c)
	return c:IsCode(CARD_SPIDERITELING) and c:IsAbleToGrave() and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
end
function s.banfilter(c)
    return c:IsCode(CARD_SPIDERITELING) and c:IsAbleToRemove()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK|LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK|LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)

end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK|LOCATION_ONFIELD,0,1,99,nil)
	if #g>0 then
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.banfilter, tp, LOCATION_GRAVE, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local g2=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_DECK,0,1,99,nil)
            if #g2>0 then
                Duel.Remove(g2, POS_FACEUP, REASON_EFFECT)
            end
        end
	end
end