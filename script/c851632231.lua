--Guardian Summoner
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --2 "Guardian" monsters that cannot be Normal Summoned
    Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	c:SetSPSummonOnce(id)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_ALL)
	e3:SetCondition(s.rewritecon)
	e3:SetOperation(s.rewriteop)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_EQUIP)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_EQUIP) and re:GetHandler():IsSpell() and re:GetHandler():IsControler(tp)
	end)
	e4:SetTarget(s.addtgeq)
	e4:SetOperation(s.addopeq)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(WbAux.IsNonNormalSummonableGuardian,1,nil) and eg:GetFirst():GetSummonPlayer()==tp
	end)
	e5:SetTarget(s.addtgsum)
	e5:SetOperation(s.addopsum)
	c:RegisterEffect(e5)
end
s.listed_series={SET_GUARDIAN}
s.listed_names={48179391} --Seal of Orichalcos

function s.matfilter(c,fc,sumtype,tp)
    return (c:IsSetCard(SET_GUARDIAN,fc,sumtype,tp) and not c:IsSummonableCard()) or WbAux.IsNonNormalSummonableGuardian(c)
end

function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckAsCost,tp,LOCATION_MZONE|LOCATION_HAND,0,nil)
end
function s.contactop(g,tp)
	local fdg=g:Filter(Card.IsFacedown,nil)
	local gyg=g:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #fdg>0 then Duel.ConfirmCards(1-tp,fdg) end
	if #gyg>0 then Duel.ConfirmCards(1-tp, gyg) end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end

function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end

function s.orichalcosplacefilter(c)
	return c:IsCode(48179391) and not c:IsForbidden()
end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.orichalcosplacefilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.orichalcosplacefilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local fc=g:GetFirst()
		if Duel.MoveToField(fc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,5))
			e1:SetType(EFFECT_TYPE_IGNITION)
			e1:SetRange(LOCATION_FZONE)
			e1:SetCountLimit(1)
			e1:SetTarget(s.sptg)
			e1:SetOperation(s.spop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			fc:RegisterEffect(e1)

			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(id)
			e2:SetRange(LOCATION_FZONE)
			e2:SetTargetRange(1,0)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			fc:RegisterEffect(e2)


		fc:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))

		end
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GUARDIAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,math.min(ft,#g),nil)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end



--rewriting the Guardians to be Summonable
function s.notrewrittenfilter(c)
	return c:IsOriginalCode(table.unpack(WbAux.equipguardians)) and c:GetFlagEffect(id)==0
end

function s.rewritecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.notrewrittenfilter,tp,LOCATION_ALL,LOCATION_ALL,1,nil)
end

function s.rewriteop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.notrewrittenfilter,tp,LOCATION_ALL,LOCATION_ALL,nil)
	for tc in g:Iter() do
		tc:RegisterFlagEffect(id,0,0,1)
		local effs={tc:GetOwnEffects()}
		for _,eff in ipairs(effs) do
			if eff:GetCode()&EFFECT_CANNOT_SUMMON~=0 or eff:GetCode()&EFFECT_CANNOT_FLIP_SUMMON~=0 or eff:GetCode()&EFFECT_SPSUMMON_CONDITION~=0 then
				local ogcon=eff:GetCondition()
				eff:SetCondition(function(_e,...)
					return not Duel.IsPlayerAffectedByEffect(tp, id) and ogcon(_e,...)
				end)
			end
		end
	end
end

function s.addguardianfilter(c)
	return WbAux.IsNonNormalSummonableGuardian(c) and c:IsAbleToHand()
end


function s.addtgeq(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addguardianfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.addopeq(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addguardianfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.eqaddfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsSpell() and c:IsAbleToHand()
end

function s.addtgsum(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqaddfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.addopsum(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.eqaddfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--cannot special summon except Guardian monsters
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(e)
		e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp,se)
			return not c:IsSetCard(SET_GUARDIAN)
		end)
		Duel.RegisterEffect(e1,tp)
	end
end