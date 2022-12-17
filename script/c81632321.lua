--Forced Withdrawal (CT)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

function s.spfilter(c,e,tp,code)
	return c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end

function s.retfilter(c,e,tp)
    return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
     and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil, e, tp, c:GetCode())
end

function s.eqfilter(c,tp)
	return c:IsRace(RACE_INSECT) and c:CheckUniqueOnField(tp) and c:IsMonster() and not c:IsForbidden()
end

function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,nil,true) then return end

	--ATK/DEF increase
	local e2=Effect.CreateEffect(tc)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	tc:RegisterEffect(e2)

	--Equip limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(s.eqlimit)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e3)
end
function s.eqlimit(e,c)
	return c:GetControler()==e:GetHandlerPlayer()
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return true
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,100297102,0,TYPES_TOKEN,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,100297102,0,TYPES_TOKEN,500,500,1,RACE_INSECT,ATTRIBUTE_WIND) then
		local token=Duel.CreateToken(tp,100297102)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end



function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.retfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.retfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp, LOCATION_SZONE-LOCATION_FZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)

	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.SendtoHand(tc, tp, REASON_EFFECT) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local tar=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1,1,false,nil,e,tp,tc:GetCode()):GetFirst()
            if tar then
                if Duel.SpecialSummon(tar, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP) then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
                    local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
                    if ec then
                        s.equipop(tar,e,tp,ec)
                    end
                end
            end
        end
	end
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
