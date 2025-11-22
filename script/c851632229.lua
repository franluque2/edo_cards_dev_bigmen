--Ultimate Crystal Dark Rainbow Overdragon
local s,id=GetID()
function s.initial_effect(c)
    	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ADVANCED_CRYSTAL_BEAST),7)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
    e3:SetCost(s.atkcost)
    e3:SetTarget(s.atktg)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	e4:SetOperation(s.repop)
    c:RegisterEffect(e4)


end
s.listed_series={SET_ADVANCED_CRYSTAL_BEAST,SET_CRYSTAL_BEAST,SET_ULTIMATE_CRYSTAL,SET_RAINBOW_BRIDGE}
s.listed_names={CARD_ADVANCED_DARK}
function s.hspfilter(c,tp,sc)
	return c:GetLevel()==10 and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.hspfilter,1,false,1,true,c,tp,nil,false,nil,tp,c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,nil,nil,false,nil,tp,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

function s.atkfilter(c)
	return c:GetAttack()>0 and c:IsSetCard(SET_CRYSTAL_BEAST)
end

function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.atkfilter,1,false,nil,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,s.atkfilter,1,1,false,nil,c)
    e:SetLabelObject(g:GetFirst())
    Duel.Release(g,REASON_COST)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0)
    local tc=e:GetLabelObject()
    if tc and tc:IsPreviousAttributeOnField(ATTRIBUTE_DARK) then
        Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    end
end

function s.addfilter(c)
    return c:IsSetCard(SET_RAINBOW_BRIDGE) and c:IsAbleToHand()
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=e:GetLabelObject()
    if c:IsFaceup() and c:IsRelateToEffect(e) and tc then
        --This card gains ATK equal to the Tributed monster's until the end of the turn
        local atk=tc:GetPreviousAttackOnField()
        if atk<0 then atk=0 end
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        --then, if you Tributed a DARK monster to activate this effect, you can add 1 "Rainbow Bridge" card from your Deck to your hand
        if tc:IsPreviousAttributeOnField(ATTRIBUTE_DARK) and Duel.GetFlagEffect(tp, id)==0 and Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
                Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)
            end
        end
    end
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(function(tc)
        return tc:IsFaceup() and tc:IsControler(tp) and tc:IsCode(CARD_ADVANCED_DARK)
    end,1,c) or c:IsFaceup() and c:IsControler(tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsSetCard),tp,LOCATION_REMOVED,0,1,1,nil,SET_ADVANCED_CRYSTAL_BEAST)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
        return true
    else return false end
end

function s.repfilter(c,tp,ec)
	return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:IsFaceup() 
		and ((c:IsControler(tp) and c:IsCode(CARD_ADVANCED_DARK)) 
		or (c==ec))
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp,c)
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_REMOVED,0,1,nil,SET_ADVANCED_CRYSTAL_BEAST) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_REMOVED,0,1,1,nil,SET_ADVANCED_CRYSTAL_BEAST)
		e:SetLabelObject(g:GetFirst())
		return true
	end
	return false
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer(),e:GetHandler())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
    Duel.SendtoGrave(tc, REASON_EFFECT+REASON_REPLACE)
end

