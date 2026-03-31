--Protoss Hardened Shields
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)

end
s.listed_series={SET_PROTOSS}

function s.tgfilter(c)
	return c:IsSetCard(SET_RADIANT_TYPHOON) and c:IsMonster() and c:IsAbleToGrave()
end
function s.thfilter(c)
	return c:IsCode(CARD_MYSTICAL_SPACE_TYPHOON) and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id) and Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+1)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
	elseif op==2 then
        Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)

	end
end
function s.discardfilter(c)
	return (c:IsSetCard(SET_PROTOSS)) and c:IsDiscardable(REASON_EFFECT)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Discard 1 "Protoss" card, and if you do, draw 2 cards.
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
        local g=Duel.SelectMatchingCard(tp,s.discardfilter,tp,LOCATION_HAND,0,1,1,nil)
        if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT|REASON_DISCARD)>0 then
            Duel.Draw(tp,2,REASON_EFFECT)
        end
		
	elseif op==2 then
        --Until the end of this chain, other "Protoss" cards in your possession are unaffected by your opponent's card effects.
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetTargetRange(LOCATION_ONFIELD|LOCATION_HAND,0)
        e1:SetTarget(function(_e,c) return c:IsSetCard(SET_PROTOSS) and c~=_e:GetHandler() end)
        e1:SetValue(function(_e,te) return te:GetOwnerPlayer()~=_e:GetHandlerPlayer() end)
        e1:SetReset(RESET_CHAIN)
        Duel.RegisterEffect(e1,e:GetHandlerPlayer())

		end
end
