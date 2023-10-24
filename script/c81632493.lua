--Critical Service (CT)
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)	
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

end

function s.cfilter(c,tp,re)
	return c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(5)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,re)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.sendcybersefilter(c)
    return c:IsRace(RACE_CYBERSE) and c:HasLevel() and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) and Duel.IsExistingMatchingCard(s.sendcybersefilter, tp, LOCATION_HAND, 0, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
                local send=Duel.SelectMatchingCard(tp, s.sendcybersefilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
                if send and Duel.SendtoGrave(send, REASON_EFFECT) then
                    local lv=send:GetFirst():GetLevel()
                    Duel.Damage(1-tp, lv, REASON_EFFECT)
                end
            end
		end
end