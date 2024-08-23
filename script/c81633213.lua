--Shackles for the Wandering Destruction Dragon of Souls
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here 
        
        
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
        e2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
        e2:SetTarget(function(ef,c) return not c:IsOwner(ef:GetHandlerPlayer()) end)
        e2:SetValue(s.sumlimit)
        Duel.RegisterEffect(e2,tp)


        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_IMMUNE_EFFECT)
        e9:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e9:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
        e9:SetTarget(function(ef,c) return not c:IsOwner(ef:GetHandlerPlayer()) end)
        e9:SetValue(s.efilter2)
        Duel.RegisterEffect(e9, tp)

	end
	e:SetLabel(1)
end

function s.efilter2(e,te)
	return te:GetHandler():IsOriginalCode(66848311)
end


function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local mdveidos=Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ALL,LOCATION_ALL, nil, CARD_VEIDOS_ERUPTION_DRAGON)
	for tc in mdveidos:Iter() do
		if tc:GetFlagEffect(id)==0 then
            Card.Recreate(tc, 75878039, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
            Card.Recreate(tc, CARD_VEIDOS_ERUPTION_DRAGON, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)

			local eff={tc:GetCardEffect()}
			for _,teh in ipairs(eff) do
                teh:Reset()

			end

            local e1=Effect.CreateEffect(tc)
            e1:SetDescription(aux.Stringid(tc:GetOriginalCode(),0))
            e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
            e1:SetType(EFFECT_TYPE_QUICK_O)
            e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
            e1:SetCode(EVENT_FREE_CHAIN)
            e1:SetRange(LOCATION_HAND)
            e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
            e1:SetCountLimit(1,id)
            e1:SetCondition(function() return Duel.IsMainPhase() end)
            e1:SetTarget(s.sptg)
            e1:SetOperation(s.spop)
            tc:RegisterEffect(e1)
			
			local e2=Effect.CreateEffect(tc)
            e2:SetDescription(aux.Stringid(id,0))
            e2:SetCategory(CATEGORY_DESTROY)
            e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
            e2:SetProperty(EFFECT_FLAG_DELAY)
            e2:SetCode(EVENT_TO_GRAVE)
            e2:SetCountLimit(1,{id,1})
            e2:SetCondition(s.descon)
            e2:SetTarget(s.destg)
            e2:SetOperation(s.desop)
            tc:RegisterEffect(e2)

            tc:RegisterFlagEffect(id,0,0,0)

	end
    end


    local extraveidos=Duel.GetMatchingGroup(Card.IsOriginalCode, tp, LOCATION_ALL,LOCATION_ALL, nil, 08540986)
	for tc in extraveidos:Iter() do
		if tc:GetFlagEffect(id)==0 then
            Card.Recreate(tc, 16114248, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
            Card.Recreate(tc, 08540986, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,false)

			local eff={tc:GetCardEffect()}
			for _,teh in ipairs(eff) do
                teh:Reset()

			end

            Fusion.AddProcMixRep(tc,true,true,s.matfilter,2,99,CARD_VEIDOS_ERUPTION_DRAGON)


            --Cannot be destroyed by card effects
            local e1=Effect.CreateEffect(tc)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e1:SetRange(LOCATION_MZONE)
            e1:SetValue(1)
            tc:RegisterEffect(e1)
            --Your opponent cannot target it with monster effects
            local e2=e1:Clone()
            e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
            e2:SetValue(function(e,re,rp) return rp==1-e:GetHandlerPlayer() and re:IsMonsterEffect() end)
            tc:RegisterEffect(e2)
            --Destroy 1 Spell and Trap your opponent controls
            local e3=Effect.CreateEffect(tc)
            e3:SetDescription(aux.Stringid(id,1))
            e3:SetCategory(CATEGORY_DESTROY)
            e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
            e3:SetProperty(EFFECT_FLAG_DELAY)
            e3:SetCode(EVENT_SPSUMMON_SUCCESS)
            e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
            e3:SetTarget(s.stdestg)
            e3:SetOperation(s.stdesop)
            tc:RegisterEffect(e3)
            --Destroy an opponent's card that activated its effect on the field
            local e4=Effect.CreateEffect(tc)
            e4:SetDescription(aux.Stringid(tc:GetOriginalCode(),1))
            e4:SetCategory(CATEGORY_DESTROY)
            e4:SetType(EFFECT_TYPE_QUICK_O)
            e4:SetCode(EVENT_CHAINING)
            e4:SetRange(LOCATION_MZONE)
            e4:SetCountLimit(1,id)
            e4:SetCondition(s.chdescon)
            e4:SetCost(s.chdescost)
            e4:SetTarget(s.chdestg)
            e4:SetOperation(s.chdesop)
            tc:RegisterEffect(e4)


            tc:RegisterFlagEffect(id,0,0,0)

	end
    end


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.matfilter(c,fc,sumtype,tp)
	return c:IsLevelBelow(9) and c:IsRace(RACE_PYRO,fc,sumtype,tp)
end
function s.stdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.stdesop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        local tc1=g:Select(tp, 1,1,nil):GetFirst()
        Duel.Destroy(tc1, REASON_EFFECT)
	end
end
function s.chdescon(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and trig_loc&LOCATION_ONFIELD>0 and re:GetHandler():IsRelateToEffect(re)
end
function s.chdescostfilter(c)
	return c:IsSetCard(SET_ASHENED) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.chdescost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.chdescostfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.chdescostfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.chdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
end
function s.chdesop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_FZONE) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thsetfilter(c)
	return c:IsSetCard(SET_ASHENED) and c:IsContinuousTrap() and (c:IsAbleToHand() or c:IsSSetable())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP)==0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.thsetfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local sc=Duel.SelectMatchingCard(tp,s.thsetfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if not sc then return end
		Duel.BreakEffect()
		aux.ToHandOrElse(sc,tp,
			function(sc) return sc:IsSSetable() end,
			function(sc) Duel.SSet(tp,sc) end,
			aux.Stringid(id,4)
		)
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(1-tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)

	if chk==0 then return (#g>0) and (#g2>0) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,tp,0)

end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if (#g>0) and (#g2>0) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        local tc1=g:Select(tp, 1,1,nil):GetFirst()
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        local tc2=g2:Select(tp, 1,1,nil):GetFirst()
        local g3=Group.FromCards(tc1,tc2)
		Duel.Destroy(g3,REASON_EFFECT)
	end
end