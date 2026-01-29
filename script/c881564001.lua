--Illfated Guardian - Archer
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
		Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Cannot be Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
	c:RegisterEffect(e1)

    --always a correct material
    	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCode(id)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(511002961)
    c:RegisterEffect(e3)

    --if this card is normal or special summoned: you can add 1 "Fated Chant" or 1 card that mentions it from your deck or gy to your hand
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetTarget(s.target)
    e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e4:SetOperation(s.operation)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e5)

    WbAux.IncreaseFatedChantUses(c)
end
s.listed_names={CARD_FATED_CHANT}
s.listed_series={SET_FATED}

local oldfunc=Link.ConditionFilter

function Link.ConditionFilter(c,fc,og,sg,lv)
	if c:IsHasEffect(id) then
		return true
	end
	return oldfunc(c,fc,og,sg,lv)
end

local oldfunc2=Xyz.MatFilter2

function Xyz.MatFilter2(c,f,lv,xyz,tp)
    if c:IsHasEffect(id) then
        return true
    end
    return oldfunc2(c,f,lv,xyz,tp)
end


function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(SET_FATED)
end

function s.adfilter(c)
    return (c:IsCode(CARD_FATED_CHANT) or c:ListsCode(CARD_FATED_CHANT)) and c:IsAbleToHand() and not c:IsCode(id)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end