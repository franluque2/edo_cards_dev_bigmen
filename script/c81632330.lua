--The☆Recyclone (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.equipfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:IsAbleToDeckAsCost()
end

function s.highlevelfilter(c)
    return (c:IsLevelAbove(7) or c:IsRankAbove(7) or c:IsLinkAbove (3)) and c:IsFaceup()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.equipfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) 
        and Duel.IsExistingMatchingCard(s.highlevelfilter, tp, 0, LOCATION_MZONE, 1, nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #dg>0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.equipfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	if Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_COST)>0 then
		local dg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 then
			local sg=dg:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			if Duel.Destroy(sg,REASON_EFFECT) and sg:GetFirst():IsType(TYPE_EQUIP) and sg:GetFirst():IsSpell() and Duel.IsPlayerCanDraw(tp) and Duel.SelectYesNo(tp, aux.Stringid(id, 0))
            then
                Duel.Draw(tp, 2, REASON_EFFECT)
            end
		end
	end
end
