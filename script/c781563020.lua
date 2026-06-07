--Decoded Destruction
Duel.LoadScript("big_skill_aux.lua")
local s, id = GetID()
function s.initial_effect(c)
    
    local e1, e2 = BSkillaux.CreateBasicSkill(c, id, s.flipconpassive, s.flipoppassive, nil,s.flipconactive, s.flipopactive, true, nil)

	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

    aux.GlobalCheck(s, function()
		s.used_this_skill = {}
        s.used_this_skill[0] = false
        s.used_this_skill[1] = false
    end)
end


function s.flipconpassive(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, id) == 0 and Duel.GetCurrentChain() == 0
end

function s.flipoppassive(e, tp, eg, ep, ev, re, r, rp)
    Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1 << 32))
    local c = e:GetHandler()


     local e12=Effect.CreateEffect(e:GetHandler())
		e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e12:SetCode(EVENT_CHAINING)
		e12:SetCondition(s.discon4)
		e12:SetOperation(s.disop2)
        e12:SetCountLimit(1)
		Duel.RegisterEffect(e12,tp)

    --"Decode Talker" you control gain 500 ATK for each "Code Talker" monster in your GY with a different name.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(function(_,c) return c:IsCode(01861629) end)
    e1:SetValue(s.atkval)
    Duel.RegisterEffect(e1,tp)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_ADD_SETCODE)
    e2:SetTargetRange(LOCATION_ALL,0)
    e2:SetTarget(function(_,c) return c:IsOriginalCode(97383507) end)
    e2:SetValue(SET_CODE_TALKER)
    Duel.RegisterEffect(e2,tp)


    s.rewritecards(e,tp,eg,ep,ev,re,r,rp)
end

function s.atkfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_CODE_TALKER)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)*500
end

function s.repfilter2(c)
    return c:IsOriginalCode(97383507)
end

function s.rewritecards(e,tp,eg,ep,ev,re,r,rp)

    local g = Duel.GetMatchingGroup(s.repfilter2, e:GetHandlerPlayer(), LOCATION_ALL, 0, nil)
	for tc in g:Iter() do
		local effs = { tc:GetOwnEffects() }
		for _, eff in ipairs(effs) do
			if eff:GetCode()&EVENT_SPSUMMON_SUCCESS==EVENT_SPSUMMON_SUCCESS then
				local neweff = eff:Clone()
				eff:Reset()
                neweff:SetTarget(s.sptg1)
	            neweff:SetOperation(s.spop1)
				tc:RegisterEffect(neweff)
			end
		end
	end

end


function s.spfilter(c,e,tp,zone)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler():GetLinkedZone(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,ft,ft,nil,e,tp,zone)
	for sc in sg:Iter() do
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP,zone)~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e2)
		end
	end
	Duel.SpecialSummonComplete()
end

function s.flipconactive(e, tp, eg, ep, ev, re, r, rp)
    return (not s.used_this_skill[e:GetHandlerPlayer()]) and aux.CanActivateSkill(e:GetHandlerPlayer()) and Duel.GetLP(tp)<=1000
end

function s.flipopactive(e, tp, eg, ep, ev, re, r, rp)
    s.used_this_skill[e:GetHandlerPlayer()] = true
    Duel.Hint(HINT_CARD, tp, id)

    local firewall=Duel.CreateToken(tp, 05043010)
    Duel.SendtoDeck(firewall, tp, SEQ_DECKTOP, REASON_RULE)
end


function s.discon4(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsCode(86066372)
		and re:IsHasCategory(CATEGORY_DESTROY)
end

function s.disop2(e,tp,eg,ep,ev,re,r,rp)
        local e17=Effect.CreateEffect(e:GetHandler())
        e17:SetType(EFFECT_TYPE_FIELD)
        e17:SetCode(EFFECT_CANNOT_TRIGGER)
        e17:SetTargetRange(LOCATION_MZONE,0)
        e17:SetTarget(s.actfilter4)
        e17:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e17, tp)
end

function s.actfilter4(e,c)
    return c:IsCode(86066372)
end