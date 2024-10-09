--Hati of the Nordic Beasts
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)


    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,2})
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END|TIMING_BATTLE_START)
    e4:SetCondition(s.rmcon)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
end
s.listed_series={0x42,0x4b}

function s.nonnordicfilter(c)
    return c:IsFaceup() and not c:IsSetCard({0x42,0x4b})
end


function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x4b), tp, LOCATION_MZONE, 0, 1, nil)
end

function s.chgfilter(c)
	return c:GetControler()~=c:GetOwner()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return true end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	for tc in aux.Next(g) do
		if not tc:IsImmuneToEffect(e) then
			tc:ResetEffect(EFFECT_SET_CONTROL,RESET_CODE)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_CONTROL)
			e1:SetValue(tc:GetOwner())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-(RESET_TOFIELD+RESET_TEMP_REMOVE+RESET_TURN_SET))
			tc:RegisterEffect(e1)
		end
	end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_MUST_ATTACK)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1, tp)
end




function s.filter(c)
	return c:IsSetCard(0x42) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)

        local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	end
end

function s.splimit(e,c)
	return not c:IsSetCard({0x42,0x4b})
end



function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.nonnordicfilter,tp,LOCATION_MZONE,0,nil)==0
end

function s.changetgfilter(c)
    return c:IsPosition(POS_DEFENSE) and c:IsCanChangePosition()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    local sg=Duel.GetMatchingGroup(s.changetgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,1,0,0)

end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and Duel.IsExistingMatchingCard(s.changetgfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DEFENSE)
            local tc=Duel.SelectMatchingCard(tp, s.changetgfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1,1,false,nil):GetFirst()
            Duel.HintSelection(tc)
            Duel.ChangePosition(tc, POS_FACEUP_ATTACK)
        end
	end
end