--Edge-Imp Wings
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)

    Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	c:SetSPSummonOnce(id)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.equiptg)
	e2:SetOperation(s.equipop)
	c:RegisterEffect(e2)


end
s.listed_named={CARD_POLYMERIZATION}
s.listed_series={SET_FRIGHTFUR,SET_FLUFFAL,SET_EDGE_IMP}

function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard({SET_FRIGHTFUR,SET_FLUFFAL,SET_EDGE_IMP},fc,sumtype,tp)
	and c:IsMonster()
    and not c:IsCode(id)
end


function s.thfilter(c)
	return (c:IsCode(CARD_POLYMERIZATION)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
function s.contactop(g,tp)
	local fu,fd=g:Split(Card.IsFaceup,nil)
	if #fu>0 then Duel.HintSelection(fu,true) end
	if #fd>0 then Duel.ConfirmCards(1-tp,fd) end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end

function s.frightfurfusionfilter(c)
    return c:IsSetCard(SET_FRIGHTFUR) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end

function s.equiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsSetCard(SET_FRIGHTFUR) and chkc:IsType(TYPE_FUSION) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.frightfurfusionfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.frightfurfusionfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local c=e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.equipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsControler(1-tp) then return end
	if Duel.Equip(tp,c,tc) then
		--Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
		

        local e5=Effect.CreateEffect(c)
        e5:SetDescription(aux.Stringid(id,2))
        e5:SetType(EFFECT_TYPE_QUICK_O)
        e5:SetCode(EVENT_FREE_CHAIN)
        e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e5:SetRange(LOCATION_MZONE)
        e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
        e5:SetCountLimit(1)
        e5:SetCondition(s.condition)
        e5:SetTarget(s.destg)
        e5:SetOperation(s.desop)

        local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e3:SetRange(LOCATION_SZONE)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(s.eftg)
		e3:SetLabelObject(e5)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
end

function s.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local tn=Duel.GetTurnPlayer()
    return tn~=tp and Duel.IsMainPhase()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local thisc=e:GetHandler()
    if not thisc:IsPosition(POS_FACEUP_ATTACK) then return end
    if tc:IsRelateToEffect(e) then
        Duel.CalculateDamage(e:GetHandler(), tc)
    end
end