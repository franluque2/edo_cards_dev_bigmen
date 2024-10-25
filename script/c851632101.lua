--Heimdall of the Nordic Alfar
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.selfreleasecost)
    e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetValue(0x4b)
	c:RegisterEffect(e3)

end
s.listed_series={0x42,0x4b,0x5042}

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x4b), tp, LOCATION_MZONE, 0, 1, nil)
end

function s.filter(c,scard,sumtype,tp)
	return c:IsSetCard(0x4b) and c:IsAbleToExtra()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end

	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
    if Duel.SendtoDeck(g, tp, SEQ_DECKTOP, REASON_EFFECT) then
        Duel.BreakEffect()
        for tc in g:Iter() do
            if tc:IsLocation(LOCATION_EXTRA) and tc:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false,false) then
                Duel.SpecialSummonStep(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
                tc:CompleteProcedure()
            end
        end
        Duel.SpecialSummonComplete()
    end
end




function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0x42,scard,sumtype,tp) and c:IsLevelBelow(5)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())

	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.setfilter(c)
	return ((c:IsSetCard(0x5042) and c:IsTrap()) or c:IsCode(14464864) )and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end

function s.banfilter(c,tp)
	return c:IsSetCard(0x42) and c:IsMonster() and c:IsAbleToRemove(tp)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)

    local tc=Duel.SelectMatchingCard(tp, s.banfilter, tp, LOCATION_HAND|LOCATION_DECK, 0, 1,1,false,nil)
    if Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) then
        
    
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,false,nil)
	if #g>0 then
		Duel.SSet(tp,g)

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
    end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c)
	return not c:IsSetCard({0x42,0x4b})
end