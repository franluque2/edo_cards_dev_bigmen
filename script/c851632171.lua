--Happy Burger
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()


    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.SelfReveal)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FLIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon)
	e2:SetCost(Cost.DetachFromSelf(1,1,nil))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)

end

s.listed_series={SET_RECIPE,SET_FRIESLA}
s.listed_names={30243636} --"Hungry Burger"
function s.thfilter(c,e,tp)
	return c:IsSetCard(SET_FRIESLA) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0, tp, false,false,POS_FACEDOWN_DEFENSE)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc, 0, tp,tp, false,false, POS_FACEDOWN_DEFENSE)>0 and sc:IsLocation(LOCATION_MZONE) then
		Duel.ConfirmCards(1-tp,sc)
		if c:IsRelateToEffect(e) then
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end


function s.valiadttachfilter(c)
    return c:IsCode(30243636) and c:IsFaceup() and c:GetBaseAttack()==2000
end

function s.repcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==tp and eg:IsExists(s.valiadttachfilter, 1, nil)
end

function s.toattachfilter(c)
	return c:IsSetCard(SET_FRIESLA) and c:IsMonster()
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:Filter(s.valiadttachfilter, nil)
    if not tc then return end
    local tc1=tc:GetFirst()

    if tc1 then
        if Duel.IsPlayerCanSpecialSummonMonster(tp, 30243636, 0, TYPE_MONSTER+TYPE_EFFECT+TYPE_RITUAL, 2000, 1850, 6, RACE_WARRIOR, ATTRIBUTE_DARK) then
            Duel.Hint(HINT_CARD, tp, id)
            local copy=Duel.CreateToken(tp, tc1:GetOriginalCode())
			if Duel.SpecialSummon(copy, 0, tp, tp, false, false, POS_FACEUP)~=0 then
				local g=Duel.GetMatchingGroup(s.toattachfilter, tp, LOCATION_GRAVE, 0, nil)
				for toattach in g:Iter() do
					local attachcopy=Duel.CreateToken(tp, toattach:GetOriginalCode())
					Duel.Overlay(copy , attachcopy)

				end
			end
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

function s.flipfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsPreviousPosition(POS_FACEDOWN)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.flipfilter, 1, nil)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end

function s.changefilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.changefilter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local g=Duel.SelectMatchingCard(tp,s.changefilter,tp,0,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end