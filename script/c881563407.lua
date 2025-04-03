--Babidi, Sorcerer of Evil
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

    local fparams={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_DRAGON_BALL),matfilter=Fusion.OnFieldMat,extrafil=s.fextra}

    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
    e2:SetOperation(s.activate(Fusion.SummonEffTG(fparams),Fusion.SummonEffOP(fparams)))
	c:RegisterEffect(e2)

end
s.listed_series={SET_DRAGON_BALL}

function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil)
end

function s.fudballfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_DRAGON_BALL) and c:IsRace(RACE_FIEND)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.fudballfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.fudballfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.fudballfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.activate(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
            local tc=Duel.GetFirstTarget()
            if tc:IsRelateToEffect(e) and tc:IsFaceup() then
                local dam=tc:GetBaseAttack()
                if Duel.Damage(1-tp,dam,REASON_EFFECT)>0 and fustg(e,tp,eg,ep,ev,re,r,rp,0)
                and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                    Duel.BreakEffect()
                    fusop(e,tp,eg,ep,ev,re,r,rp)
        
                end
        end
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.filter(c)
	return c:IsSetCard(SET_DRAGON_BALL) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end