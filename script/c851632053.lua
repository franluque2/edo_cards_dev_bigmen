--Klassiker Burger Rezept (Classic Burger Recipe)
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    local rparams={handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.matfilter,extrafil=s.extrafil,location=LOCATION_HAND|LOCATION_DECK, forcedselection=s.ritcheck}
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target(Ritual.Target(rparams)))
	e1:SetOperation(s.operation(Ritual.Target(rparams),Ritual.Operation(rparams)))
	c:RegisterEffect(e1)


    -- Add to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.adcon)
	e3:SetCost(s.adcost)
	e3:SetTarget(s.adtg)
	e3:SetOperation(s.adop)
	c:RegisterEffect(e3)
end
s.listed_names={30243636}

function s.adcostfilter(c,tp)
	return c:IsMonster() and c:IsAbleToDeckAsCost()
end
function s.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.adcostfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.adcostfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.spconfilter(c,tp)
	return c:IsType(TYPE_RITUAL)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SendtoHand(e:GetHandler(), tp, REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp, e:GetHandler())
    end
end


function s.ritualfil(c)
	return c:IsCode(30243636) and c:IsRitualMonster()
end
function s.matfilter(c,e,tp)
	return (Duel.IsPlayerCanRelease(tp,c) and c:IsLocation(LOCATION_MZONE+LOCATION_HAND)) or s.extramatfil(c,e,tp)
end
function s.extramatfil(c,e,tp)
	return c:IsSetCard(SET_FRIESLA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.extrafil(e,tp,mg)
	if not Duel.IsPlayerCanRelease(tp) then return nil end
	return Duel.GetMatchingGroup(s.extramatfil,tp,LOCATION_DECK,0,nil,e,tp)
end
function s.ritcheck(e,tp,g,sc)
	local obj=e:GetLabelObject()
	local ct=g:FilterCount(aux.NOT(Card.IsLocation),obj,LOCATION_MZONE+LOCATION_HAND)
	return ct==0
end
function s.spfilter(c,e,tp,eg,ep,ev,re,r,rp,rittg)
	if not s.extramatfil(c,e,tp) then return false end
	e:SetLabelObject(c)
	local res=rittg(e,tp,eg,ep,ev,re,r,rp,0)
	e:SetLabelObject(nil)
	return res
end
function s.target(rittg)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp,rittg) end
		rittg(e,tp,eg,ep,ev,re,r,rp,1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
	end
end
function s.operation(rittg,ritop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp,rittg)
		if #sg==0 then return end
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.BreakEffect()
			e:SetLabelObject(sg:GetFirst())
			ritop(e,tp,eg,ep,ev,re,r,rp)
			e:SetLabelObject(nil)
		end
	end
end