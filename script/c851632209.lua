--Odin, All-Knowing Father of the Aesir
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(nil),1,99)
    	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)

    --Aesir monsters you control are unaffected by your opponent's monster effects, except during main phase 2
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetCondition(function(e) return Duel.GetCurrentPhase()~=PHASE_MAIN2 end)
    e2:SetTarget(function(e,c) return c:IsSetCard(SET_AESIR) and c:IsFaceup() end)
    e2:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsMonsterEffect() end)
    c:RegisterEffect(e2)

    --if this card is Special Summoned: You can target up to 3 "nordic" monsters in your GY or banishment, shuffle them into the deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,0})
    e3:SetTarget(s.tdtg)
    e3:SetOperation(s.tdop)
    c:RegisterEffect(e3)

    -- During the End Phase, if this card is in your GY because it was sent there by an opponent's card this turn: You can Special Summon it, then draw until you have 5 cards in hand.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
    
    --register that it was sent to gy
    local ea4=Effect.CreateEffect(c)
	ea4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ea4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	ea4:SetCode(EVENT_TO_GRAVE)
	ea4:SetOperation(s.regop)
	c:RegisterEffect(ea4)

end
s.listed_series={SET_NORDIC,SET_NORDIC_RELIC,SET_AESIR}
function s.tfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_NORDIC,scard,sumtype,tp) or c:IsHasEffect(EFFECT_SYNSUB_NORDIC)
end

function s.todeckfilter(c)
    return c:IsSetCard(SET_NORDIC) and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.todeckfilter(chkc) end
    if chk==0 then return Duel.IsExistingMatchingCard(s.todeckfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.todeckfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,3,nil)
    Duel.HintSelection(g)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.setfilter(c)
    return c:IsSetCard(SET_NORDIC_RELIC) and c:IsSpellTrap() and c:IsSSetable()
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if #g==0 then return end
    if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
        if ft<=0 then return end
        if ft>#g then ft=#g end
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,ft,nil)
        if #sg>0 then
            Duel.SSet(tp,sg)
        end
    end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)~=0
end


function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp~=tp and c:IsPreviousControler(tp) then
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local num=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) and num>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,num)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
        local num=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
        if num>0 then
            Duel.Draw(tp,num,REASON_EFFECT)
        end
    end
end