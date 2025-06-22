--Kurichaos
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)


    	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetDescription(aux.Stringid(id,4))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_ATTACK|TIMING_BATTLE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.sscost)
	e2:SetTarget(s.sstarget)
	e2:SetOperation(s.ssoperation)
	c:RegisterEffect(e2)

		local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.condition)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
    e3:SetCountLimit(1,{id,1})
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)

end



function s.ssfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and aux.SpElimFilter(c,true,false) and c:IsAbleToRemoveAsCost()
end
function s.ssfilter1(c,sg)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and sg:IsExists(s.ssfilter2,1,c,(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)&~c:GetAttribute())
end
function s.ssfilter2(c,att)
	if att == 0 then att = ATTRIBUTE_LIGHT|ATTRIBUTE_DARK end
	return c:IsAttribute(att)
end
function s.ssrescon(sg,e,tp,mg)
	return sg:IsExists(s.ssfilter1,1,nil,sg) and aux.ChkfMMZ(1)(sg,e,tp,mg)
end
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.ssfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.ssrescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.ssrescon,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.sstarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,Group.FromCards(c),1,tp,0)
end
function s.ssoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end



function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPhase(PHASE_MAIN1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,5,nil) and Duel.IsPlayerCanDraw(tp,5) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)

    local g=Duel.GetDecktopGroup(tp, 5)
    if #g~=5 then return end

    Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id, 1))
    Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_CONFIRM)
    local g1=g:Select(1-tp, 0, #g, nil)
    g:Sub(g1)
    if #g1>0 then
        Duel.ConfirmCards(tp, g1)
    end

    if #g1>0 and (#g==0 or Duel.SelectYesNo(tp, aux.Stringid(id, 2))) then
        Duel.SendtoHand(g1, tp, REASON_EFFECT)
        if #g>0 then
            Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
        end
        Duel.ConfirmCards(1-tp, g1)
    else
        Duel.SendtoHand(g, tp, REASON_EFFECT)
        if #g>0 then
            Duel.Remove(g1, POS_FACEUP, REASON_EFFECT)
        end
        Duel.ConfirmCards(1-tp, g)
    end

	Duel.BreakEffect()
	Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE|PHASE_END,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end