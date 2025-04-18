--Graydle Slime Spawn
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.condition)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)


end
s.listed_series={0xd1}



function s.spcfilter(c)
	return c:IsSetCard(0xd1) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return re:GetHandler():IsSetCard(0xd1)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.sumfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, true, true)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_WATER) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalAttribute(ATTRIBUTE_WATER) end)


	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<=0 then return end
    
    local g=Duel.GetMatchingGroup(s.sumfilter,tp,0,LOCATION_DECK,nil,e,tp)
	local dcount=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	local seq=-1
	local spcard=nil
	for tc in g:Iter() do
		if tc:GetSequence()>seq then
			seq=tc:GetSequence()
			spcard=tc
		end
	end
	if seq==-1 then
		Duel.ConfirmDecktop(1-tp,dcount)
		Duel.ShuffleDeck(1-tp)
		return
	end
	Duel.ConfirmDecktop(1-tp,dcount-seq)
    if spcard==nil then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and spcard:IsCanBeSpecialSummoned(e,0,tp,true,true) then
        Duel.DisableShuffleCheck()
        if dcount-seq==1 then Duel.SpecialSummon(spcard,0,tp,tp,true,true,POS_FACEUP)
		else
			Duel.SpecialSummonStep(spcard,0,tp,tp,true,true,POS_FACEUP)
			Duel.SpecialSummonComplete()
		end
        Duel.ShuffleDeck(1-tp)
    end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (e:GetHandler():GetReason()&0x41)==0x41
end

function s.thfilter(c)
	return not c:IsCode(id) and c:IsAbleToHand()
		and c:IsSetCard(0xd1)
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD|LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
		if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
            local togravg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil)
            local tograv=aux.SelectUnselectGroup(togravg,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
            Duel.SendtoGrave(tograv,REASON_EFFECT)
		end
	end
end
