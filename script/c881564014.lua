--The Fated Caster of Prophecy
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

        local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)
        local sme,soe=Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	sme:SetOperation(s.mretop)

    -- If this card is Normal Summoned: You can Special Summon 1 Level 4 "Fated" Spirit monster from your hand or Deck, (but shuffle it into the deck if this card leaves the field), but it cannot activate its effects while it is face up on the field.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetTarget(s.sptg)
    e2:SetCountLimit(1,{id,0})
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    --If this card attacks an opponent's monster: you can banish 1 spell card from your GY; take control of that opponent's monster.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_CONTROL)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_START)
    e3:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0 end)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.takecost)
    e3:SetTarget(s.taketg)
    e3:SetOperation(s.takeop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_FATED}

function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(SET_FATED)
end


function s.mretop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsDiscardable, tp, LOCATION_HAND, 0, REASON_COST)
	if not (#g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 4))) then return Spirit.ReturnOperation(e,tp,eg,ep,ev,re,r,rp) end
	
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)

end

function s.spfilter(c,e,tp)
    return c:IsLevel(4) and c:IsSetCard(SET_FATED) and c:IsType(TYPE_SPIRIT)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then


        			c:SetCardTarget(tc)
			--Register when this card is about the leave the field
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_LEAVE_FIELD_P)
			e2:SetOperation(s.regop)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e2)


        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESETS_STANDARD)
		tc:RegisterEffect(e1)

        Duel.SpecialSummonComplete()
    end
end


function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if not (tc and tc:IsLocation(LOCATION_MZONE)) then return end
	--Shuffle it into the Deck when this card leaves the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_RULE)
	end
	e:Reset()
end

function s.banishfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end


function s.takecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.banishfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.taketg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local at=Duel.GetAttackTarget()
    if chk==0 then return c==Duel.GetAttacker() and at and at:IsControler(1-tp) and at:IsControlerCanBeChanged(false) end
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,at,1,1-tp,LOCATION_MZONE)
end

function s.takeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local at=Duel.GetAttackTarget()

    if not at then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if at:IsRelateToBattle() and at:IsControler(1-tp) then
        Duel.GetControl(at, tp)
    end
end