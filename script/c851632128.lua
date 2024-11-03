--Hrgrignath, the Nightmare
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,2)


    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetTargetRange(1,0)
    e2:SetCondition(s.spcon)
	e2:SetValue(s.extraval)
	c:RegisterEffect(e2)


    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end)


    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)




    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCategory(CATEGORY_REMOVE)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.atcon)
	e4:SetTarget(s.attg)
	e4:SetOperation(s.atop)
	c:RegisterEffect(e4)


    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)


end
s.listed_names={CARD_ABYSSAL_DREDGE}

function s.counterfilter(c)
	return c:IsRace(RACE_REPTILE)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_REPTILE)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()==tp then return end
    local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
        if tc:GetPreviousLocation()==LOCATION_EXTRA then
            Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE|PHASE_END|RESET_OPPO_TURN,0,1)
            return
        end
	end
end


function s.matfilter(c,rc,st,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,rc,st,tp) and c:IsRace(RACE_REPTILE,rc,st,tp)
end

function s.spcon(e)
	return Duel.GetFlagEffect(1-e:GetHandlerPlayer(),id)>=3
end


function s.extraval(chk,summon_type,e,...)

	if chk==0 then

		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and sc==e:GetHandler()) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(Card.IsCanBeLinkMaterial,tp,LOCATION_HAND,0,nil,e:GetHandler())
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end



function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, LOCATION_MZONE, e:GetHandler())>0
end

function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return WbAux.CanPlayerSummonDredge(tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local num=Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, LOCATION_MZONE, e:GetHandler())
    if num>Duel.GetLocationCount(tp,LOCATION_MZONE) then num=Duel.GetLocationCount(tp,LOCATION_MZONE) end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then num=1 end
	if num<1 then return end
	local tossummon=Duel.AnnounceNumberRange(tp,1,num)

	if not Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_ABYSSAL_DREDGE,nil,TYPE_MONSTER+TYPE_EFFECT,0,0,4,RACE_REPTILE,ATTRIBUTE_DARK,POS_FACEUP,tp,0) then return end

	for i = 1, tossummon, 1 do
		local dredge=Duel.CreateToken(tp, CARD_ABYSSAL_DREDGE)
		Duel.SpecialSummonStep(dredge, SUMMON_TYPE_SPECIAL, tp, tp, false,false, POS_FACEUP)	
	end
	Duel.SpecialSummonComplete()
end



function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.atfilter(c)
	return c:IsCode(CARD_ABYSSAL_DREDGE) and c:IsAbleToRemove()
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atfilter(chkc) and c:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.atfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_MZONE,0,1,1,nil,lg)

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,nil,REASON_EFFECT|REASON_TEMPORARY)>0 and tc:IsLocation(LOCATION_REMOVED)
		and not tc:IsReason(REASON_REDIRECT) then
		Duel.BreakEffect()
		Duel.ReturnToField(tc)
	end
    
end
