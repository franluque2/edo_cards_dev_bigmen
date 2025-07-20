--PSY-Framelord Ypsilon
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.matcheck)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
    e1:SetCountLimit(1, id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)


    	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(CARD_PSYFRAME_LAMBDA)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)


    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)


    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)

end
s.listed_names={CARD_PSYFRAME_DRIVER, 00575512} --Psyframe Circuit
s.listed_series={SET_PSY_FRAME}

function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsCode,1,nil,CARD_PSYFRAME_DRIVER)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.cfilter(c,tp)
	local re=c:GetReasonEffect()
	return c:IsFaceup() and c:IsSummonPlayer(tp) and re:GetHandler():IsSetCard(SET_PSY_FRAME) and re:GetHandler():IsType(TYPE_TUNER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.cfilter,nil,tp)
	if chk==0 then return (#g>0) and e:GetHandler():IsLinkSummonable() end
    Duel.ConfirmCards(1-tp, e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.LinkSummon(tp, c)
	end

	    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetCode(EFFECT_SKIP_TURN)
    e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN)
    Duel.RegisterEffect(e1,tp)
end


function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local circuit=Duel.CreateToken(tp, 00575512)
	Duel.MoveToField(circuit,tp,tp,LOCATION_FZONE,POS_FACEUP,true)



end



function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:GetFirst()
	return #eg==1 and tg:GetSummonType()==SUMMON_TYPE_SYNCHRO
end

function s.thfilter(c)
	return c:IsSetCard(SET_PSY_FRAME) and c:IsMonster() and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end

    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(0xff,0)
	e1:SetTarget(s.rmtg)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,4))
end


function s.rmtg(e,c)
	local tp=e:GetHandlerPlayer()
	return c:GetOwner()==tp and Duel.IsPlayerCanRemove(tp,c) and not c:IsType(TYPE_SYNCHRO)
end