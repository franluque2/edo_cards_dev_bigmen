--Umbryas, Harbinger of the End Times
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,99,s.spcheck)
	

    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK) or (c:IsCode(CARD_ABYSSAL_DREDGE) or c:ListsCode(CARD_ABYSSAL_DREDGE)) end)


    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,_c)return _c:IsSummonLocation(LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK) and not (c:IsCode(CARD_ABYSSAL_DREDGE) or c:ListsCode(CARD_ABYSSAL_DREDGE)) end)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.adval)
	c:RegisterEffect(e4)


		local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_BE_PRE_MATERIAL)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetOperation(s.reset)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_LEAVE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e8:SetOperation(s.reset)
	c:RegisterEffect(e8)


end
s.listed_names={CARD_ABYSSAL_DREDGE, 851632008}


function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and WbAux.CanPlayerSummonDredge(tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 
		and WbAux.CanPlayerSummonDredge(tp) then
            for i = 1, 2, 1 do
                local dredge=Duel.CreateToken(tp, CARD_ABYSSAL_DREDGE)
                Duel.SpecialSummonStep(dredge, SUMMON_TYPE_SPECIAL, tp, tp, false,false,POS_FACEUP)
            end
            Duel.SpecialSummonComplete()
	end	
end

function s.adval(e,c)
	return WbAux.GetDredgeCount(e:GetHandler():GetControler())*500
end
function s.spcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSummonCode,1,nil,lc,sumtype,tp,851632008)
end

function s.matfilter(c,rc,st,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,rc,st,tp)
end

function s.copfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)==0
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,CARD_ABYSSAL_DREDGE),tp,LOCATION_MZONE,0,nil)
    if #g==0 then return end
    for tc in g:Iter() do
        local wg=Duel.GetMatchingGroup(s.copfilter,tp,0,LOCATION_MZONE,tc)
        for wbc in aux.Next(wg) do
            if tc:IsFaceup() then
                local cid=tc:CopyEffect(wbc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_CONTROL,1)
                wbc:RegisterFlagEffect(id,0,0,0,cid)
            end
        end
    end
end

function s.rfilter(c)
	return c:GetFlagEffect(id)>0
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	local wg=eg:Filter(s.rfilter,nil)
	for wbc in aux.Next(wg) do
			local g=e:GetMatchingGroup(aux.FaceupFilter(Card.IsCode,CARD_ABYSSAL_DREDGE),tp,LOCATION_MZONE,0,nil)
			if #g==0 then return end
			for tc in g:Iter() do
				tc:ResetEffect(wbc:GetFlagEffectLabel(id),RESET_COPY)
				wbc:ResetFlagEffect(id)
		end
	end
end