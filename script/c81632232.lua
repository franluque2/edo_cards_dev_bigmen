--Insect Garden (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
    e4:SetCountLimit(1,id)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)


end

function s.thcfilter2(c)
	return c:IsFaceup() and c:IsCode(37957847)
end

function s.pheromonefilter(c)
    return c:IsCode(511000550) and c:IsSSetable()
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.thcfilter2(chkc) end
	if chk==0 then return eg:IsExists(s.thcfilter2,1,nil) and Duel.IsExistingMatchingCard(s.pheromonefilter, tp, LOCATION_DECK, 0, 1,nil) end
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(s.pheromonefilter, tp, LOCATION_DECK, 0, nil)
    if tc then
        Duel.SSet(tp, tc)
    end
end

function s.thcfilter(c,e)
	return s.controlfilter(c) and c:IsCanBeEffectTarget(e)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local num=Duel.GetMZoneCount(1-tp)
	if chkc then return eg:IsContains(chkc) and s.thcfilter(chkc,e) end
	if chk==0 then return eg:IsExists(s.thcfilter,1,nil,e) end
	if #eg==1 then
		Duel.SetTargetCard(eg)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sg=eg:FilterSelect(tp,s.thcfilter,1,num,nil,e)
		Duel.SetTargetCard(sg)
	end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,0,0,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if #tc>0 then
		Duel.GetControl(tc, 1-tp)
	end
end


function s.controlfilter(c)
    return c:IsRace(RACE_INSECT) and c:IsLevelBelow(4) and c:IsAbleToChangeControler() and c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local num=Duel.GetMZoneCount(1-tp)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and s.controlfilter(chkc) end
	if chk==0 then return true end
    if Duel.GetMatchingGroupCount(s.controlfilter, tp, LOCATION_MZONE, 0, nil)>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
        local g=Duel.SelectTarget(tp,s.controlfilter,tp,LOCATION_ONFIELD,0,0,num,nil)
        Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,#g,0,0)
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tc then
		Duel.GetControl(tc, 1-tp)
	end
end