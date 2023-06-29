--Level Pod (CT)
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
    e1:SetCountLimit(1,id)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)


    	--Take no battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.condition)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)

end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetBattleMonster(tp)
	return Duel.GetBattleDamage(tp)>0 and tc and tc:IsCode(81632242)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end


function s.filter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local rg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	Duel.SendtoDeck(rg1,nil,2,REASON_EFFECT)
	rg1=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	local rg2=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SendtoDeck(rg2,nil,2,REASON_EFFECT)
	rg2=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	Duel.BreakEffect()
    local g=Group.CreateGroup()
    g:Merge(rg1)
    g:Merge(rg2)
	if #rg1>0 then
		Duel.ShuffleDeck(tp)
	end
	if #rg2>0 then
		Duel.ShuffleDeck(1-tp)
	end
    local sum=0
    local levmax=g:GetMaxGroup(Card.GetLevel)
    local ranmax=g:GetMaxGroup(Card.GetRank)
    local linmax=g:GetMaxGroup(Card.GetLink)

    if levmax then
        if levmax:GetFirst():GetLevel()>sum then
            sum=levmax:GetFirst():GetLevel()
        end
    end

    if ranmax then
        if ranmax:GetFirst():GetRank()>sum then
            sum=ranmax:GetFirst():GetRank()
        end
    end

    if linmax then
        if linmax:GetFirst():GetLink()>sum then
            sum=linmax:GetFirst():GetLink()
        end
    end

	Duel.DiscardDeck(tp, sum, REASON_EFFECT)
	Duel.DiscardDeck(1-tp, sum, REASON_EFFECT)
end
