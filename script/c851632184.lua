--Allure Queen Pretender
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)

    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e0:SetValue(87257460)
	c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(s.eqconignition)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,s.eqconignition,s.eqval,s.equipop,e1)
	--Quick Effect version for when the effect of "Golden Allure Queen" is applied
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_STANDBY_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCondition(s.eqconquick)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,s.eqconquick,s.eqval,s.equipop,e2)

    	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetValue(aux.tgoval)
	c3:RegisterEffect(e3)

end

s.listed_names={87257460} --"Allure Queen LV3"


function s.eqconignition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:GetEquipGroup():IsExists(Card.HasFlagEffect,1,nil,id) and not (c:IsOriginalSetCard(SET_ALLURE_QUEEN) and Duel.IsPlayerAffectedByEffect(tp,EFFECT_GOLDEN_ALLURE_QUEEN))
end
function s.eqconquick(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:GetEquipGroup():IsExists(Card.HasFlagEffect,1,nil,id)
		and c:IsOriginalSetCard(SET_ALLURE_QUEEN) and Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),EFFECT_GOLDEN_ALLURE_QUEEN)
end

function s.tarfunc(c)
    return c:IsAbleToChangeControler() and not c:HasLevel()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() and not chkc:HasLevel() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.tarfunc,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.tarfunc,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then
		Duel.SendtoGrave(c,REASON_RULE,PLAYER_NONE,PLAYER_NONE)
	else
		s.equipop(c,e,tp,tc)
	end
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id) then return end
	--If this card would be destroyed by battle, the equipped monster is destroyed instead
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e1:SetValue(function(e,re,r,rp) return r&REASON_BATTLE>0 end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
function s.eqval(ec,c,tp)
	return ec:IsControler(1-tp)
end

function s.fuequippedmonfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:GetEquipTarget():IsSetCard(SET_ALLURE_QUEEN)
end

function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.fuequippedmonfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.tgtg(e,c)
	return not (c:IsType(TYPE_EQUIP) and c:IsSpell() and c:IsFaceup())
end