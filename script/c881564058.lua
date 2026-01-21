--Illyasviel the Fated Vessel
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --You can send this card from your hand or field to the GY; add 1 "The Fated Holy Grail" from your Deck or GY to your hand, also until the end of your next turn, "The Fated Holy Grail" you control cannot be destroyed by card effects.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --Once per Duel, during your Main Phase: You can banish this card and 7 "Fated" Spirit monsters with different names from your GY; discard your hand, and if you do, Special Summon 1 monster from either GY, ignoring its summoning conditions, even if it was not properly summoned. This effect and its activation cannot be negated. 
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    e2:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_DISABLE)
    c:RegisterEffect(e2)


end
s.listed_names={881564016, 881564006} --Illya the Fated Master, The Fated Holy Grail

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.thfilter(c)
    return c:IsCode(881564006) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end

    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetTargetRange(LOCATION_ONFIELD,0)
    e1:SetTarget(function(_,c) return c:IsCode(881564006) and c:IsFaceup() end)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
    Duel.RegisterEffect(e1,tp)
end

function s.banishfilter(c)
    return c:IsSetCard(SET_FATED) and c:IsType(TYPE_SPIRIT) and c:IsAbleToRemoveAsCost()
end

function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:GetClassCount(Card.GetCode)==#sg,sg:GetClassCount(Card.GetCode)~=#sg
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(100)
	return true
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)

    local rg=Duel.GetMatchingGroup(s.banishfilter, tp, LOCATION_GRAVE, 0, nil)
    local spg=Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, nil, e, tp)
    if chk==0 then
    if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and e:GetHandler():IsAbleToRemoveAsCost()
            and rg:GetClassCount(Card.GetCode)>=7
            and ((#spg>#rg) or #spg>7)
        end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
    local g=aux.SelectUnselectGroup(rg,e,tp,7,7,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
    Duel.Remove(g,POS_FACEUP,REASON_COST)

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT|REASON_DISCARD)
    else 
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
    end
end