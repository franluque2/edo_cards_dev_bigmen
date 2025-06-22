--Apoqliphort Observer
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_QLI),3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit2,nil,nil,nil,false)

    --splimit
        local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_HAND_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(0)
	c:RegisterEffect(e1)


    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.efilter)
	c:RegisterEffect(e5)

    	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)


    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_PZONE)
	e6:SetOperation(s.handes)
	c:RegisterEffect(e6)


end
s.listed_series={SET_QLI}
function s.splimit(e,c)
	return not c:IsSetCard(SET_QLI)
end


function s.splimit2(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or e:GetHandler():GetLocation()~=LOCATION_EXTRA 
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
end


function s.efilter(e,te)
	if te:IsSpellTrapEffect() then
		return true
	else
		return s.levelchk(e,te)
	end
end

function s.levelchk(e,te)
	if te:IsActiveType(TYPE_MONSTER) and te:IsActivated() then
		local lv=e:GetHandler():GetOriginalLevel()
		local ec=te:GetOwner()
		if ec:IsType(TYPE_LINK) then
			return ec:GetLink()<lv
		elseif ec:IsType(TYPE_XYZ) then
			return ec:GetRank()<lv
		else
			return ec:GetLevel()<lv
		end
	else
		return false
	end
end


function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() and Duel.IsExistingMatchingCard(s.tohandfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.tohandfilter(c,e,tp)
	return c:IsSetCard(SET_QLI) and c:IsAbleToHand()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) then
		if re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
		if not c:IsRelateToEffect(e) then return end
		Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local rg=Duel.SelectMatchingCard(tp,s.tohandfilter,tp,LOCATION_PZONE,0,1,1,nil)
		if #rg>0 then
			Duel.BreakEffect()
			Duel.HintSelection(rg,true)
			if Duel.SendtoHand(rg,nil,REASON_EFFECT)>0 then
                Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
            end
		end

	end
end

function s.filter(c,p)
	return c:IsFaceup() and c:IsSetCard(SET_QLI) and c:IsControler(p) and c:IsOriginalType(TYPE_MONSTER)
end

function s.fuqlifilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_QLI)
end

s[0]=0
function s.handes(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc,chain_id,targetcards=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_CHAIN_ID,CHAININFO_TARGET_CARDS)
	if not (ep==1-tp and chain_id~=s[0] and targetcards and targetcards:IsExists(s.filter,1,nil,tp)) then return end
	s[0]=chain_id
    local num=Duel.GetMatchingGroupCount(s.fuqlifilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
    if num==0 then return end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=num and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
		Duel.DiscardHand(1-tp,nil,num,num,REASON_EFFECT|REASON_DISCARD,nil)
		Duel.BreakEffect()
	else Duel.NegateEffect(ev) end
end