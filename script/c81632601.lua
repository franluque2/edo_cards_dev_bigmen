--Sacred Arrow (CT)
local s,id=GetID()
function s.initial_effect(c)
c:SetUniqueOnField(1,0,511001266)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)

	--cannot be target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.etarget)
	e3:SetValue(s.evalue)
	c:RegisterEffect(e3)

    --Pop 'N Search
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)

    --Set Backrow
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_LEAVE_GRAVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,{id,2})
	e5:SetTarget(s.eptg)
	e5:SetOperation(s.epop)
	c:RegisterEffect(e5)


	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.op)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.chkfilter(c,tp)
	return c:IsMonster() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_GRAVE) 
		and c:IsPreviousControler(tp)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ct1=eg:FilterCount(s.chkfilter,nil,tp)
	local ct2=eg:FilterCount(s.chkfilter,nil,1-tp)
	if ct1>0 then
		s[0]=s[0]+ct1
	end
	if ct2>0 then
		s[1]=s[1]+ct2
	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,s[0]*200)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,s[1]*200)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Damage(tp,s[0]*200,REASON_EFFECT,true)
	Duel.Damage(1-tp,s[1]*200,REASON_EFFECT,true)
	Duel.RDComplete()
end


function s.etarget(e,c)
	return c:IsCode(511001977, 511001978, 511001980, 511001979, 30757396)
end
function s.evalue(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

function s.filter(c)
	return c:IsFacedown()
end

function s.thfilter(c)
	return c:IsCode(511001977, 511001978, 511001980, 511001979) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_SZONE,1,e:GetHandler()) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

function s.eptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,0,LOCATION_GRAVE,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,LOCATION_GRAVE)
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
    local g=Duel.SelectMatchingCard(1-tp,s.setfilter,tp,0,LOCATION_GRAVE,1,1,nil):GetFirst()
		if g and g:IsSSetable() then 
			Duel.SSet(1-tp,g)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			g:RegisterEffect(e1)
	end
end
function s.setfilter(c)
	return c:IsSpellTrap() and c:IsSSetable()
end
function s.erascon(e)
	return e:GetHandler():IsReason(REASON_DESTROY)
end