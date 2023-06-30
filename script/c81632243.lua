--Monster Register (CT)
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,c:Alias())

	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.econ)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.tftg)
	e5:SetOperation(s.tfop)
	c:RegisterEffect(e5)

end
s.listed_names={81632242}

function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,Duel.GetTurnPlayer(),LOCATION_MZONE,0,1,nil) 
		and Duel.IsPlayerCanDiscardDeck(Duel.GetTurnPlayer(), 1) end
	Duel.SetTargetPlayer(ep)

	local g=Duel.GetMatchingGroup(Card.IsFaceup, Duel.GetTurnPlayer(),LOCATION_MZONE, 0, nil)

	local sum=0
    local levmax=g:GetMaxGroup(Card.GetLevel)
    local ranmax=g:GetMaxGroup(Card.GetRank)
    local linmax=g:GetMaxGroup(Card.GetLink)

    if levmax then
        if levmax:GetFirst():GetLevel()>sum then
            sum=levmax:GetFirst():GetLevel()
        end
    end

    if ranmax then
        if ranmax:GetFirst():GetRank()>sum then
            sum=ranmax:GetFirst():GetRank()
        end
    end

    if linmax then
        if linmax:GetFirst():GetLink()>sum then
            sum=linmax:GetFirst():GetLink()
        end
    end

	Duel.SetTargetParam(sum)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,ep,sum)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.DiscardDeck(p, d, REASON_EFFECT)
end

function s.rockfliponfilter(c,tp)
	return c:IsControler(tp) and c:IsRace(RACE_ROCK) and c:IsType(TYPE_FLIP) and c:IsFaceup() and c:IsCanTurnSet()
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rockfliponfilter,1,nil,tp)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.rockfliponfilter, nil, tp)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end


function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and (te:GetOwner():IsType(TYPE_FLIP))
end
function s.econ(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceup, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil, Card.IsCode, 81632242)
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.cfilter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_ROCK) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_FLIP) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=g:Select(tp,1,1,nil)
		Duel.SendtoHand(tc, tp, REASON_EFFECT)
	end
end