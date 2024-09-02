--Spirit Guide & Shaded Melody
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),1,99)
	c:EnableReviveLimit()
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

    --Return itself to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end

local yokaigirls={14558127,52038441,60643553,62015408,73642296,851632010}

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1800) end
	Duel.PayLPCost(tp,1800)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
        local name=Duel.SelectCardsFromCodes(tp,1,1,false,false,yokaigirls)
        Duel.Hint(HINT_CARD, tp, name)
        Card.Recreate(c, name, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)

        if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
		    Duel.ConfirmCards(1-tp,c)
        end
	end
end

function s.cfilter(c,seq)
	return (seq-1>=0 and c:GetSequence()==seq-1) or (seq+1<=4 and c:GetSequence()==seq+1)
end

function s.filter(c,tp,hc)
	return c:IsControler(tp) and ((c==hc and c:IsSummonType(SUMMON_TYPE_SYNCHRO)) or (s.cfilter(c,hc:GetSequence())))
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp,e:GetHandler())
end

function s.thfilter(c)
	return c:IsMonster() and c:IsType(TYPE_TUNER) and c:IsDefense(1800) and c:IsAttack(0) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)

        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(_e,_c) return _c:IsCode(_e:GetLabel()) end)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e2,tp)
	end
end