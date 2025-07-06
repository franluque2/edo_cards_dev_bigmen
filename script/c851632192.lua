--Mythical Beast of Endymion
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableCounterPermit(COUNTER_SPELL,LOCATION_PZONE|LOCATION_MZONE)
	Pendulum.AddProcedure(c)
	--Add counter to itself
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--Special Summon from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(s.sptg1)
    e2:SetCountLimit(1,id)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
	--Special Summon from deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
	--Counter check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_DESTROY)
	e0:SetOperation(s.ctchk)
	e0:SetLabel(0)
	c:RegisterEffect(e0)
	--Place itself in the `Pendulum Zone when destroyed
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetLabelObject(e0)
	e5:SetCondition(s.pencon)
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)

    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return c:IsRace(RACE_SPELLCASTER) end)

end
s.counter_place_list={COUNTER_SPELL}

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return re:IsSpellEffect()
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() and re:GetHandler()~=c then
		c:AddCounter(COUNTER_SPELL,1)
	end
end
function s.spfilter(c,e,tp)
	return c:IsCanAddCounter(COUNTER_SPELL,1,false,LOCATION_MZONE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetUsableMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
            and c:IsDestructable()
            and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)==0
         end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)

     local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsRace(RACE_SPELLCASTER) end)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e)
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<1
		or Duel.GetUsableMZoneCount(tp)<1 then
		return end
        if Duel.Destroy(c, REASON_EFFECT)~=1 then return end
        Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==2 then
			g:ForEach(Card.AddCounter,COUNTER_SPELL,1)
		end
	end
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
            and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
            and not e:GetHandler():IsStatus(STATUS_CHAINING)
         end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK|LOCATION_HAND)

end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
        Duel.SpecialSummonStep(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
    if Duel.SpecialSummonComplete()==2 then
        g:ForEach(Card.AddCounter,COUNTER_SPELL,1)
        local c=e:GetHandler()
        if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
            c:AddCounter(COUNTER_SPELL,1)
        end
    else
        Duel.ShuffleDeck(tp)
    end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsRace(RACE_SPELLCASTER) end)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.ctchk(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetCounter(COUNTER_SPELL))
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r&REASON_EFFECT+REASON_BATTLE~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabelObject():GetLabel()
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and (ct==0 or e:GetHandler():IsCanAddCounter(COUNTER_SPELL,ct,false,LOCATION_PZONE)) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and ct>0 then
		Duel.BreakEffect()
		c:AddCounter(COUNTER_SPELL,ct)
	end
end