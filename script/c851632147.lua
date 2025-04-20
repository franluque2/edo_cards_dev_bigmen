--Paleozoic Wiwaxia
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	c:SetSPSummonOnce(id)

    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(function(e,_,rc) return 2 end)
	c:RegisterEffect(e0)

    --Unaffected by monsters' effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter2)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.extraval)
	c:RegisterEffect(e2)
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_ADD_TYPE)
	e2a:SetRange(LOCATION_EXTRA)
	e2a:SetTargetRange(LOCATION_HAND,0)
	e2a:SetCondition(s.addtypecon)
	e2a:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_PALEOZOIC))
	e2a:SetValue(TYPE_MONSTER)
	c:RegisterEffect(e2a)


    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,{id,1})
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsSetCard(SET_PALEOZOIC)) end)

end
s.listed_series={SET_PALEOZOIC}

function s.efilter2(e,re)
	return re:IsMonsterEffect() and re:GetOwner()~=e:GetOwner()
end


function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_PALEOZOIC,scard,sumtype,tp) and (c:IsMonster() or c:IsTrap() and c:IsLocation(LOCATION_HAND))
end


function s.filter(c)
    return c:IsTrap() and c:IsSetCard(SET_PALEOZOIC)
end
function s.extraval(chk,summon_type,e,...)

	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and sc==e:GetHandler()) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end
function s.addtypecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end


function s.filter2(c,e,tp)
	return c:IsSetCard(SET_PALEOZOIC) and c:IsTrap() and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetOriginalCode(),0xd4,0x11,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
            and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
         end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsSetCard(SET_PALEOZOIC)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
        local c=g:GetFirst()
		c:AddMonsterAttribute(TYPE_NORMAL)
		c:AssumeProperty(ASSUME_RACE,RACE_AQUA)
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		c:AddMonsterAttributeComplete()
		--Unaffected by monster effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3101)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		--Banish it if it leaves the field
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3300)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
	end
end

function s.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end