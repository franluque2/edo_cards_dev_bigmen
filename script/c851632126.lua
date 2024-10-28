--Cosmic Corruptor Cz'asz
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	c:SetSPSummonOnce(id)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1174)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
    e1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon2)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)


end

s.listed_series={0xc}
s.counter_list={COUNTER_A}



function s.thfilter(c)
	return c:ListsCounter(COUNTER_A) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.monfilter(c)
    return c:IsFaceup() and c:GetCounter(COUNTER_A)>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.monfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc1=g:Select(tp, 1,1,true,nil)
    if not tc1 then return false end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc2=g:Select(tp, 1,1,true,tc1:GetFirst())
    if tc1 and tc2 then
    local g2=Group.FromCards(tc1:GetFirst(),tc2:GetFirst())
    if g2 then
		g2:KeepAlive()
		e:SetLabelObject(g2)
		return true
	end
end
	return false
end

function s.spcon(e,c)
	if c==nil then return true end

    local g=Duel.GetMatchingGroup(s.monfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)

	return Duel.GetLocationCountFromEx(c:GetControler(), c:GetControler()) and
		#g>1
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return false end
        local tc1=g:GetFirst()
        local tc2=g:GetNext()
        tc1:RemoveCounter(tp,COUNTER_A,1,REASON_COST)
        tc2:RemoveCounter(tp,COUNTER_A,1,REASON_COST)
end



function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and (Duel.IsMainPhase())
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and not tc:IsImmuneToEffect(e) then
        local cardid=tc:GetOriginalCode()
        Card.Recreate(tc, id+1, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)

        local de=Effect.CreateEffect(e:GetHandler())
        de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        de:SetCode(EVENT_PHASE+PHASE_BATTLE)
        de:SetReset(RESET_PHASE+PHASE_BATTLE)
        de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        de:SetCountLimit(1)
        de:SetLabel(cardid)
        de:SetLabelObject(tc)
        de:SetOperation(s.desop2)
        Duel.RegisterEffect(de,tp)
    
        tc:RegisterFlagEffect(0,RESET_PHASE+PHASE_BATTLE,EFFECT_FLAG_CLIENT_HINT,1,1,aux.Stringid(id,2))

	end
end

function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local fid=e:GetLabel()
    Card.Recreate(g, fid, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
end