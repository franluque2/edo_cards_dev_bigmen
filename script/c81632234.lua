--Mantis Egg (CT)
Duel.LoadScript ("big_aux.lua")
local s,id=GetID()
local TOKEN_BABY_MANTIS=id+1
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_RELEASE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon1)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)


    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCondition(s.changecon)
	e3:SetOperation(s.changeop)
	c:RegisterEffect(e3)

    --special summon
    local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetCondition(function(_,tp)return Duel.GetTurnPlayer()==tp end)
	e5:SetTarget(s.sptg2)
	e5:SetOperation(s.spop2)
	c:RegisterEffect(e5)

end
s.listed_series={0x535}

function s.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsReason(REASON_RELEASE) and c:GetTurnID()==Duel.GetTurnCount()
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end


function s.cfilter(c,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsRace(RACE_INSECT) and pp&POS_FACEUP>0 and np&POS_FACEUP>0 and np~=pp and c:IsControler(tp)
end
function s.changecon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=eg:Filter(s.cfilter, nil, tp)
    
    if g then
        local tc=g:GetFirst()
        while tc do
            --cannot be destroyed by battle
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e1:SetDescription(3000)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            e1:SetRange(LOCATION_MZONE)
			e1:SetValue(1)
			tc:RegisterEffect(e1)

            tc=g:GetNext()
        end
    end
end

function s.cfilter1(c,tp)
	return c:IsMonster() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsRace(RACE_INSECT)
end
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,nil,tp)
end

function s.dreadfilter(c)
    return c:IsCode(66973070) and c:IsMonster() and c:IsFaceup()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCode(66973070) end
	if chk==0 then return Duel.IsExistingTarget(s.dreadfilter, tp, LOCATION_MZONE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,s.dreadfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc then
        local c=e:GetHandler()
        local b1=not tc:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT)
        local b2=not tc:IsHasEffect(EFFECT_CANNOT_BE_EFFECT_TARGET)
        local b3=not tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
        local dtab={}
        if b1 then
            table.insert(dtab,aux.Stringid(id,0))
        end
        if b2 then
            table.insert(dtab,aux.Stringid(id,1))
        end
        if b3 then
            table.insert(dtab,aux.Stringid(id,2))
        end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVEEFFECT)
        local op=Duel.SelectOption(tp,table.unpack(dtab))+1
        if not (b1 or b2) then op=3 end
        if not (b1 or b3) then op=2 end
        if (b1 and b3 and not b2 and op==2) then op=3 end
        if (b2 and b3 and not b1) then op=op+1 end
        if op==1 then
            --cannot be destroyed by card effs
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e1:SetDescription(3001)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetRange(LOCATION_MZONE)
			e1:SetValue(1)
			tc:RegisterEffect(e1)

        elseif op==2 then
            --cannot be targetted
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
            e1:SetDescription(3061)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetRange(LOCATION_MZONE)
			e1:SetValue(aux.tgoval)
			tc:RegisterEffect(e1)
        elseif op==3 then
            --cannot be destroyed by battle
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e1:SetDescription(3000)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetRange(LOCATION_MZONE)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
        end
    end
end


function s.thfilter(c)
	return c:IsMonster() and (c:IsCTMantis() or c:IsCode(66973070)) and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.mantfilter(c)
	return c:IsFaceup() and c:IsMonster() and (c:IsCTMantis() or c:IsCode(66973070)) and c:IsAbleToHand()
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.mantfilter, tp, LOCATION_MZONE, 0, 1, nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31600514,0,TYPES_TOKEN,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31600514,0,TYPES_TOKEN,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) then
		local token=Duel.CreateToken(tp,31600514)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
