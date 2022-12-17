--Shogi World (CT)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Line Monster 500 atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLineMonster))
	e2:SetValue(500)
	c:RegisterEffect(e2)
    --banish destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.rmtarget)
	e2:SetTargetRange(0,LOCATION_ONFIELD)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)

    --search
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.thcost1)
	e3:SetTarget(s.thtg1)
	e3:SetOperation(s.thop1)
	c:RegisterEffect(e3)
end

function s.cfilter1(c)
	return c:IsLineMonster() and c:IsMonster() and not c:IsPublic()
end

function s.movefilter(c,tp)
    return c:IsControler(1-tp) and c:IsFaceup() and c:IsCanTurnSet()
end
function s.thcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
    e:SetLabel(g:GetFirst():GetCode())
	Duel.ShuffleHand(tp)
end
function s.thfilter1(c, code)
	return c:IsLineMonster() and c:IsAbleToHand() and not c:IsCode(code)
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.movefilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE,tp)>0 and Duel.IsExistingTarget(s.movefilter, tp, 0, LOCATION_MZONE, 1, nil, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_OPPO)
    local tc=Duel.SelectTarget(tp, s.movefilter, tp, 0, LOCATION_MZONE, 1, 1, false, nil , tp)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()

    if tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then

        if not Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEDOWN,true) then return end
		--Treated as a Continuous Trap
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
        if Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end 
        end
        
    end
end

function s.linefilter(c,tp)
    return c:IsLineMonster() and c:IsControler(tp)
end

function s.rmtarget(e,c)
	if not c:IsLocation(0x80) and c:IsReason(REASON_DESTROY) and ((c:IsReason(REASON_BATTLE) and c:GetBattleTarget():IsLineMonster()) or (c:IsReason(REASON_EFFECT) and c:GetReasonEffect():GetHandler():IsLineMonster())) then
		return true
	else
		return false
	end
end