--Delta Reactor (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.bfgcost)
    e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={16898077}
function s.spcfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost()
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),52286175,15175429,89493368)
end
function s.chk(c,sg,g,code,...)
	if not c:IsCode(code) then return false end
	local res
	if ... then
		g:AddCard(c)
		res=sg:IsExists(s.chk,1,g,sg,g,...)
		g:RemoveCard(c)
	else
		res=true
	end
	return res
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local g1=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE,0,nil,52286175)
	local g2=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE,0,nil,15175429)
	local g3=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE,0,nil,89493368)
	local g=g1:Clone()
	g:Merge(g2)
	g:Merge(g3)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #g1>0 and #g2>0 and #g3>0 
		and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg, POS_FACEUP, REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsCode(16898077) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.spfilter,tp,0x13,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,0x13)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,0x13,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
        tc:CompleteProcedure()
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	return true
end

function s.spsumsalvofilter(c,e,tp)
    return c:IsCode(88671720) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.spsumdmachinefilter(c,e,tp)
    return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.scfilter2(c,mg)
	return c:IsRace(RACE_MACHINE) and c:IsSynchroSummonable(nil,mg)
end

function s.scfilter1(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.scfilter2,tp,LOCATION_EXTRA,0,1,nil,mg)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local salvos=Duel.GetMatchingGroup(s.spsumsalvofilter, tp, LOCATION_GRAVE|LOCATION_REMOVED,0, nil,e,tp)
	return (not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)) and (not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
        and salvos and (#salvos>0)
        and Duel.IsExistingMatchingCard(s.spsumdmachinefilter, tp, LOCATION_GRAVE|LOCATION_REMOVED, 0, 1, nil,e,tp, salvos:GetFirst()) and Duel.IsPlayerCanSpecialSummonCount(tp,2)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
        and Duel.IsExistingMatchingCard(s.scfilter1,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp, salvos:GetFirst())
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x10b) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spsumsalvofilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,s.scfilter1,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp,g:GetFirst())

    Group.Merge(g, g2)

	for tc in g:Iter() do
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
    end
	Duel.SpecialSummonComplete()
	local gsync=Duel.GetMatchingGroup(s.scfilter2,tp,LOCATION_EXTRA,0,nil,g)
	if #gsync>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=gsync:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
