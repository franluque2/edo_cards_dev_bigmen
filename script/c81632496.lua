--Starry Cyberse (CT)
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)	

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    
end

function s.attackcybersefilter(c)
    return c:IsRace(RACE_CYBERSE) and c:IsPosition(POS_FACEUP_ATTACK)
end

function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp, 3) 
        and Duel.IsExistingMatchingCard(s.attackcybersefilter, tp, LOCATION_MZONE, 0, 1, nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local group=Duel.GetDecktopGroup(tp, 3)
    
	if Duel.DiscardDeck(tp, 3, REASON_EFFECT) then
        local tar=Duel.SelectMatchingCard(tp, s.attackcybersefilter, tp, LOCATION_MZONE, 0, 1,1,false,nil):GetFirst()
        local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3000)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(1)
		tar:RegisterEffect(e2)

        local filtermonster=group:Filter(Card.IsMonster, nil)
        if #filtermonster>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            local lvls=filtermonster:GetSum(Card.GetLevel)

            local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lvls*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tar:RegisterEffectRush(e1)
        end
	end
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_GRAVE) and (c:IsLevel(7) or c:IsLevel(8))
end