--Friesla Biergarten - "Auf Los"
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    --activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

    --extra summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	e2:SetRange(LOCATION_FZONE)
	c:RegisterEffect(e2)
	
    -- discard replacement

    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(CARD_FRIESLA_BIERGARTEN)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetCountLimit(1,{id,1})
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)

    --add back to hand

    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1)
	e4:SetCondition(s.adcon)
	e4:SetTarget(s.adtg)
	e4:SetOperation(s.adop)
	c:RegisterEffect(e4)
end

function s.spconfilter(c,tp)
	return c:IsType(TYPE_RITUAL)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsAbleToHand()
end
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.spconfilter,1,nil,tp) end
    local g=eg:Filter(s.spconfilter, nil, tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_GRAVE)
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.spconfilter, nil, tp)
    Duel.HintSelection(g)
	if Duel.SendtoHand(g, tp, REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp, g)
    end
end



function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return c:IsMonster() and c:IsSetCard(SET_FRIESLA) and Duel.CheckLPCost(tp, c:GetDefense())
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    Duel.PayLPCost(tp, c:GetDefense())
    Duel.ChangePosition(c,POS_FACEUP_DEFENSE)

end