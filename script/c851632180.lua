--Qliphort Cloud
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)

    local ep2=Effect.CreateEffect(c)
	ep2:SetDescription(aux.Stringid(id,4))
	ep2:SetCategory(CATEGORY_SUMMON)
	ep2:SetType(EFFECT_TYPE_IGNITION)
	ep2:SetRange(LOCATION_PZONE)
	ep2:SetCountLimit(1)
	ep2:SetCondition(s.condition)
	ep2:SetTarget(s.target)
	ep2:SetOperation(s.operation)
	c:RegisterEffect(ep2)


    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.bantarget)
	e3:SetOperation(s.banoperation)
	c:RegisterEffect(e3)

    local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(aux.qlifilter)
	c:RegisterEffect(e7)

    local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_RELEASE)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e8:SetTarget(s.destg)
	e8:SetOperation(s.desop)
	c:RegisterEffect(e8)

end

s.listed_series={SET_QLI}
function s.splimit(e,c)
	return not c:IsSetCard(SET_QLI)
end


function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),SET_QLI)
end
function s.sumfilter(c)
	return c:IsSetCard(SET_QLI) and c:IsSummonable(true,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end


function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_QLI)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end



function s.bantarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)

end

function s.banoperation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
        for tc in g:Iter() do
            Duel.ReturnToField(tc)
        end
    end
end


function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	Duel.Destroy(sg,REASON_EFFECT)
	sg=Duel.GetOperatedGroup()
	local d1=0
	local d2=0
	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		if tc then
			if tc:IsPreviousControler(0) then d1=d1+1
			else d2=d2+1 end
		end
	end
	if d1>0 and Duel.IsExistingMatchingCard(s.adtohandfilter, 0, LOCATION_DECK, 0, d1, nil) and Duel.SelectYesNo(0,aux.Stringid(id,3)) then s.tohandop(0,d1) end
	if d2>0 and Duel.IsExistingMatchingCard(s.adtohandfilter, 1, LOCATION_DECK, 0, d2, nil) and Duel.SelectYesNo(1,aux.Stringid(id,3)) then s.tohandop(1,d2) end
end

function s.adtohandfilter(c)
    return c:IsMonster() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end

function s.tohandop(p, num)
    local g=Duel.GetMatchingGroup(s.adtohandfilter,p,LOCATION_DECK,0,nil)
    if #g>=num then
        Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
        local sg=g:Select(p,num,num,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-p,sg)
    end
end