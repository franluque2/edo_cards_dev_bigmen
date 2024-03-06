--Praime Dry Saucer (CT)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.sendtogravefilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(7) and c:IsAbleToGraveAsCost()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.sendtogravefilter, tp, LOCATION_HAND, 0, nil)
	if chk==0 then return #dg>0 end
end
function s.desfilter(c)
	return c:IsFaceup() and (c:IsLevelBelow(9) or c:IsRankBelow(9) or c:IsLinkBelow(4))
end

function s.differenttypefilter(c,c2)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(7) and not c:IsRace(c2:GetRace())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local cost=Duel.SelectMatchingCard(tp, s.sendtogravefilter, tp, 1, 1, false, nil)
    local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,e:GetHandler())
    if #dg==0 then return end
    if Duel.IsExistingMatchingCard(s.differenttypefilter, tp, LOCATION_MZONE, 0, 1, nil, cost:GetFirst()) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        local sg=dg:Select(tp,1,1,nil)
        sg=sg:AddMaximumCheck()
        Duel.HintSelection(sg)
        if Duel.Destroy(sg,REASON_EFFECT)>0 then
            if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,1-tp,LOCATION_GRAVE,0,1,nil,e,1-tp)
            and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
                Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
                local g=Duel.SelectMatchingCard(1-tp,s.spfilter,1-tp,LOCATION_GRAVE,0,1,1,nil,e,1-tp)
                if #g>0 then
                    Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP)
                end
            end
        end
    
        
    end
end
function s.spfilter(c,e,sp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
