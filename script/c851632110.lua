--Vampire Half-Breed
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,nil,2,2,s.lcheck)
	


    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
	e2:SetCode(EFFECT_LPCOST_REPLACE)
	e2:SetCondition(s.lrcon)
	e2:SetOperation(s.lrop)
	c:RegisterEffect(e2)


    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.tgcon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

    local e4=e3:Clone()
    e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e4:SetValue(1)
    c:RegisterEffect(e4)



    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)


end

s.listed_series={SET_VAMPIRE}

function s.lrcon(e,tp,eg,ep,ev,re,r,rp)
	if tp~=ep then return false end
	if not (re and re:IsActivated()) then return false end
	local rc=re:GetHandler()
    local val=math.ceil(ev/500)
	return rc:IsSetCard(SET_VAMPIRE) and Duel.IsPlayerCanDiscardDeckAsCost(1-tp, val)
end
function s.lrop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD, tp, id)
    local val=math.ceil(ev/500)
    Duel.DiscardDeck(1-tp, val, REASON_COST)
end


function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_VAMPIRE,lc,sumtype,tp)
end


function s.tgfilter(c)
	return c:GetControler()~=c:GetOwner()
end
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(s.tgfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end


function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp) and c:IsAbleToHand() and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp) and re:GetOwner() and re:GetOwner():IsSetCard(SET_VAMPIRE)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.cfilter, nil, 1-tp)
	if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)

end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.cfilter, nil, 1-tp)
    if g then
        Duel.HintSelection(g)
        Duel.SendtoHand(g, tp, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end

