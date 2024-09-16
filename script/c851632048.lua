--Cammafrittes auf Friesla
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    --flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)

	local e2=WbAux.CreateFrieslaFlipEffect(c,s.adtar,s.adop,CATEGORY_TOHAND+CATEGORY_SEARCH)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

end
s.listed_names={30243636}

function s.filter(c)
	return c:IsSetCard(SET_FRIESLA) and not c:IsCode(id) and c:IsAbleToHand()
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
end

function s.addfilter(c)
	return c:IsSetCard(SET_RECIPE) and c:IsAbleToHand()
end
function s.adtar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
        Duel.SendtoHand(g, tp,  REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.valiadttachfilter(c)
    return c:IsCode(30243636) and c:IsFaceup()
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==tp and eg:IsExists(s.valiadttachfilter, 1, nil)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=eg:Filter(s.valiadttachfilter, nil)
    if not tc then return end

    if not Duel.IsExistingMatchingCard(aux.NOT, tp, 0, LOCATION_MZONE, 1, nil,Card.IsType,TYPE_TOKEN) then return end

    local tc1=tc:GetFirst()

    if tc1 then
        Duel.Hint(HINT_CARD, tp, id)
        local toattach=Duel.SelectMatchingCard(tp, aux.NOT, tp, 0, LOCATION_MZONE, 1,1,false,tc1,Card.IsType,TYPE_TOKEN):GetFirst()
        if toattach and not toattach:IsImmuneToEffect(e) then
            Duel.Overlay(tc1 , toattach)
        end
    end
    e:Reset()
end


function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.repcon)
    e2:SetOperation(s.repop)
    e2:SetCountLimit(1)
    Duel.RegisterEffect(e2, tp)
end