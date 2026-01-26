--Sakura the Fated Vessel
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --While you control a Spirit monster, your opponent cannot target this card for attacks, also they cannot target it with card effects.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    --Unaffected by other card effects while your opponent has 4 or more "Dregs of Angra Mainju" in their hand.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.immcon)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)


    --destroy and summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
    e4:SetCondition(function() return Duel.IsMainPhase() end)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)

end
s.listed_names={CARD_DREGS_ANGRA_MAINYU}
s.listed_series={SET_FATED}

function s.fuspiritilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end

function s.atkcon(e)
    return Duel.IsExistingMatchingCard(s.fuspiritilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end

function s.immcon(e)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    local ct=g:FilterCount(Card.IsCode,nil,CARD_DREGS_ANGRA_MAINYU)
    return ct>=4
end


function s.desfilter(c,ft)
	return c:IsFaceup() and (ft>0 or (c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5))
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_FATED) and c:IsType(TYPE_SPIRIT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc,ft) and chkc~=e:GetHandler() end
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),ft)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),ft)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        WbAux.AddDregs(1-tp,1)
    end
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
            local tc1=g:GetFirst()
			Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)

            --but its effects are negated, also its attribute becomes DARK
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc1:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc1:RegisterEffect(e2)
            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
            e3:SetValue(ATTRIBUTE_DARK)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc1:RegisterEffect(e3)


			Duel.SpecialSummonComplete()

            Duel.BreakEffect()
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
