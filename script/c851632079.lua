--Odd-Eyes Crystal Dragon
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),2,2,s.lcheck)

    Pendulum.AddProcedure(c)

	--place itself into pendulum zone on destruction
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(s.pencon)
	e6:SetTarget(s.pentg)
	e6:SetOperation(s.penop)
	c:RegisterEffect(e6)
    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_BECOME_LINKED_ZONE)
    e2:SetRange(LOCATION_PZONE)
    e2:SetValue(s.value)
    c:RegisterEffect(e2)
   

    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTarget(function(e,c) 
        return c:IsSetCard(0x99) and 
        (((1<<c:GetSequence())&s.value(e))~=0) end)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end


s.pendulum_level=7
s.listed_series={0x99,0x9f}
s.listed_names={27813661}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,{0x99,0x9f},lc,sumtype,tp)
end

function s.thfilter(c)
	return c:IsCode(27813661) and c:IsAbleToHand()
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.value(e)
    local tp=e:GetHandlerPlayer()
    local c=e:GetHandler()
    local zone=1<<c:GetSequence()

    if zone & 0x1 > 0 then
        return tp==0 and 0x3 or 0x30000
    elseif zone & 0x10 > 0 then
        return tp==0 and 0x10 or 0x100000
    end
end

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
        local des=false
        if (not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1)) then des=true end

        if (not des) and Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,nil) then
            des=Duel.SelectYesNo(tp, aux.Stringid(id, 2))
        end
        
        if des then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_PZONE,0,1,2,nil)
            if #dg>0 then
                Duel.HintSelection(dg,true)
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
        if (not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end

		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end