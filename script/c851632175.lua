--Runick Insight
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)

	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REVERSE_DECK)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.lpcon)
    e3:SetCost(Cost.SelfToGrave)
	e3:SetTarget(s.lptg)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)

end
s.listed_series={SET_RUNICK}
function s.runickfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_RUNICK) and c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.runickfilter,1,nil)
end

function s.exfilter3(c,mc)
	return c:IsSynchroSummonable(mc) or c:IsXyzSummonable(mc) or c:IsLinkSummonable(mc)
end

function s.fusfilter(c,mc,e,tp,eg,ep,ev,re,r,rp)
	return c:IsFusionSummonableCard() and c.CheckFusionMaterial(c) and Fusion.SummonEffTG(nil,Fusion.OnFieldMat,s.fusextra)(e,tp,eg,ep,ev,re,r,rp,0)
end


function s.exfilter2(c,mc,e,tp,eg,ep,ev,re,r,rp)
	return c:IsSynchroSummonable(mc) or c:IsXyzSummonable(mc) or c:IsLinkSummonable(mc) or (c:IsFusionSummonableCard() and c.CheckFusionMaterial(c) and Fusion.SummonEffTG(nil,Fusion.OnFieldMat,s.fusextra)(e,tp,eg,ep,ev,re,r,rp,0))
end

function s.runickfilter2(c,e,tp,eg,ep,ev,re,r,rp)
    return c:IsSetCard(SET_RUNICK) and c:IsMonster() and Duel.IsExistingMatchingCard(s.exfilter2,tp,LOCATION_EXTRA,0,1,nil,c,e,tp,eg,ep,ev,re,r,rp,0)
end

function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
    	if chk==0 then return Duel.IsExistingMatchingCard(s.runickfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
    	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.runickfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	if #g==0 then return end
	Duel.HintSelection(g)
    local b1=Duel.IsExistingMatchingCard(s.exfilter3,tp,LOCATION_EXTRA,0,1,nil,g:GetFirst())
    local b2=Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,g:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
    if not (b1 or b2) then return end
    local op=-1
    if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,1))
    elseif b1 then op=0
    else op=1 end
    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local xyzc=Duel.SelectMatchingCard(tp,s.exfilter3,tp,LOCATION_EXTRA,0,1,1,nil,g:GetFirst()):GetFirst()
        if xyzc then
            if xyzc:IsType(TYPE_SYNCHRO) then
            Duel.SynchroSummon(tp,xyzc,g:GetFirst())
            elseif xyzc:IsType(TYPE_XYZ) then
                Duel.XyzSummon(tp,xyzc,g:GetFirst())
            elseif xyzc:IsType(TYPE_LINK) then
                Duel.LinkSummon(tp,xyzc,g:GetFirst())
            end
        end
    elseif op==1 then
        Fusion.SummonEffOP(nil,Fusion.OnFieldMat,s.fusextra)(e,tp,eg,ep,ev,re,r,rp)
    end
end


function s.fuscheck(tp,sg,fc)
	return sg:IsExists(aux.FilterBoolFunction(Card.IsSetCard,SET_RUNICK,fc,SUMMON_TYPE_FUSION,tp),1,nil)
end
function s.fusextra(e,tp,mg)
	return nil,s.fuscheck
end