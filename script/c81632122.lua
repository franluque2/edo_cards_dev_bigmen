--Camouflage Gardna
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1, 0, id)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--place on s/t
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)

end
s.listed_names={511004336}

function s.cfilter(c)
	return c:IsFacedown() or not c:IsCode(id)
end

function s.preycounterfilter(c)
	return c:GetCounter(0x1107)>0
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IsExistingMatchingCard(s.preycounterfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) or not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g, tp, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end


function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	local g=Duel.GetAttacker()

	if g and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0) then
		if (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
			Duel.MoveToField(g,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
			g:AddCounter(0x1107,1)
		else
			Duel.MoveToField(g,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			g:AddCounter(0x1107,1)
		end
	end

end

function s.summonfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.tgfilter(c)
	return (Card.ListsCode(c,511004336) or c:IsCode(511004337) or c:IsCode(511004339) or c:IsCode(511004327) or c:IsCode(511004336) or c:IsCode(511004328)) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoHand(g, tp, REASON_EFFECT) then
			Duel.ConfirmCards(1-tp, g)
			if Duel.IsExistingMatchingCard(s.summonfilter, tp, LOCATION_DECK, 0, 1, nil,e,tp) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
				local tc=Duel.SelectMatchingCard(tp, s.summonfilter,tp,LOCATION_DECK,0, 1, 1,false,nil,e,tp)
				if tc then
					Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
				end
			end
		end
	end
end
