--Darkness Greed (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
    e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.highlevelfilter(c)
    return (c:IsLevelAbove(7) or c:IsRankAbove(7) or c:IsLinkAbove(3)) and c:IsFaceup()
end
function s.notdarkfilter(c)
    return c:IsMonster() and (not c:IsAttribute(ATTRIBUTE_DARK) or not c:IsRace(RACE_SPELLCASTER))
end

function s.darkspellcasterfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.highlevelfilter, tp, 0, LOCATION_MZONE, 1, nil) and not Duel.IsExistingMatchingCard(s.notdarkfilter, tp, LOCATION_GRAVE, 0, 1, nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.GetMatchingGroupCount(Card.IsMonster, tp, LOCATION_GRAVE, 0, nil)>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    local g=Duel.GetMatchingGroup(s.darkspellcasterfilter, tp, LOCATION_GRAVE, 0, nil)
	if Duel.Draw(p,d,REASON_EFFECT)>0 and g:GetClassCount(Card.GetCode)>3 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Draw(p,d,REASON_EFFECT)
	end
end
