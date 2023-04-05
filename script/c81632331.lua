--The☆Cancel (CT)
local s,id=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp)
end

function s.spsummonfilter(c,e)
    return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, e:GetHandlerPlayer() , false,false)
end

function s.spsummonfilter2(c,e)
    return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, e:GetHandlerPlayer(), false,false) and c:IsLevelBelow(4)
end

function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.spsummonfilter2,1,nil,e)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=eg:GetFirst()
	if chk==0 then return s.filter1(tc,tp) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,0,tc,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	--Effect
	local tc=eg:GetFirst()
    if tc and Duel.SendtoDeck(tc, tc:GetOwner(), SEQ_DECKTOP, REASON_EFFECT) then

        if Duel.IsExistingMatchingCard(s.spsummonfilter, tp, 0, LOCATION_GRAVE, 2, nil, e, tp)
         and Duel.IsExistingMatchingCard(s.spsummonfilter2, tp, 0, LOCATION_GRAVE, 1, nil, e, tp) and Duel.GetLocationCount(1-tp, LOCATION_MZONE)>0
            and Duel.SelectYesNo(1-tp, aux.Stringid(id, 0)) then
            
            local g=Duel.GetMatchingGroup(s.spsummonfilter, tp, 0, LOCATION_GRAVE, nil,e,tp)
            local tg=aux.SelectUnselectGroup(g,e,1-tp,2,2,s.rescon,1,1-tp,HINTMSG_SPSUMMON)

            if tg then
                Duel.SpecialSummon(tg, SUMMON_TYPE_SPECIAL, 1-tp, 1-tp, false,false, POS_FACEUP)
            end
         end

         local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(0,1)
		e1:SetTarget(function(e,c) return c:IsCode(e:GetLabel()) end)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)


    
    end
end
