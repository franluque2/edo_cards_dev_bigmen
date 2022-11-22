--Malefi Ladybug of the Sleeping Forest (CT)
local s,id=GetID()
function s.initial_effect(c)
	
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	
end


function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanChangePosition() end
end

function s.monstertodestroy(c)
    return c:IsFaceup() and (c:IsLevelBelow(7) or not c:HasLevel()) 
end

function s.summonablemonster(c,e,tp)
    return c:IsCode(id) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.monstertodestroy,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)~=0 then
		--Effect
        local tc=Duel.SelectMatchingCard(tp, s.monstertodestroy, tp, 0, LOCATION_MZONE, 1, 1,false,nil)
        if #tc>0 then
            if Duel.Destroy(tc, REASON_EFFECT) then
                Duel.BreakEffect()
                if Duel.Damage(1-tp, 700, REASON_EFFECT) then
                    if Duel.IsExistingMatchingCard(s.summonablemonster, tp, LOCATION_HAND, 0, 1, nil, e, tp) and Duel.SelectYesNo(tp, aux.Stringid(91110378, 0)) then
                        local tc2=Duel.SelectMatchingCard(tp, s.summonablemonster, tp, LOCATION_HAND, 0, 1,1,false,nil,e,tp)
                        if tc2 then
                            Duel.BreakEffect()
                            Duel.SpecialSummon(tc2, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)
                        end
                    end
                end
            end
        end
	end
end
