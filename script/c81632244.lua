--Purse with a Hole (CT)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)

    	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_names={511001236,81632242}

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsCode(511001236) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsControler(tp) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end


function s.furegfilter(c)
    return c:IsCode(511001236) and c:IsFaceup()
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>5 and Duel.IsExistingMatchingCard(s.furegfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)-3)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if #g>0 then
		while Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>3 do
			Duel.BreakEffect()
			local sg=g:RandomSelect(p,1)
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
			g:RemoveCard(sg:GetFirst())
		end
	end
end
