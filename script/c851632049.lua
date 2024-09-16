--Urielkase auf Friesla
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    --flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)

	local e2=WbAux.CreateFrieslaFlipEffect(c,s.sptar,s.spop,CATEGORY_SPECIAL_SUMMON)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetCondition(function(e) return e:GetHandler():IsCode(30243636) end)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

end
s.listed_names={30243636}

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_FRIESLA) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE+POS_FACEDOWN_DEFENSE)
end
function s.sptar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE+POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,g)
	end
end


function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
    local e1=WbAux.CreateFrieslaAttachEffect(c)
    Duel.RegisterEffect(e1, tp)
end