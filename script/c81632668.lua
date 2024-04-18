--Comic Field (CT)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.destg)
	e4:SetValue(s.desval)
	c:RegisterEffect(e4)
    --multi attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--attack
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_FZONE)
	e5:SetHintTiming(TIMING_BATTLE_START+TIMING_BATTLE_PHASE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.atcon2)
	e5:SetTarget(s.attg2)
	e5:SetOperation(s.atop2)
	c:RegisterEffect(e5)
end
function s.thfilter(c)
	return c:IsCode(511002153, 511002697, 511003223, 511000984, 511002580) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.dfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsReason(REASON_EFFECT) and c:IsComicsHero() and c:GetOverlayCount()~=0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:FilterCount(s.dfilter,nil)==1 end
	Duel.Hint(HINT_CARD,0,id)
	local g=eg:Filter(s.dfilter,nil)
	local tc=g:GetFirst()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(500)
	tc:RegisterEffect(e1)
	return true
end
function s.desval(e,c)
	return c:IsFaceup() and c:IsOnField() and c:IsReason(REASON_EFFECT) and c:IsComicsHero() and c:GetOverlayCount()~=0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x511)
end
function s.atcon2(e,tp,eg,ev,ep,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x511),tp,LOCATION_MZONE,0,1,nil)
end
function s.attg2(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.atop2(e,tp,eg,ev,ep,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_PHASE|PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end

function s.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_CANNOT_ATTACK) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and (c:IsAttackPos() or c:IsHasEffect(EFFECT_DEFENSE_ATTACK))
end