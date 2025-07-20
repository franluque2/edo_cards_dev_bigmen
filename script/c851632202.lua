--Submareened Force
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)			
    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)


	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.discon)
	e2:SetCost(Cost.SelfDiscard)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if Duel.GetTurnPlayer()==tp then return false end
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_HANDES)
	local ex1,_,_,cp2,cv2=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	local ex2,_,_,cp3,cv3=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	local ex3,_,_,cp4,cv4=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	if not (ex or ex1 or ex2 or ex3) then return false end
 	if (re:IsHasCategory(CATEGORY_HANDES) and ex and not (cp==tp or cp==PLAYER_ALL)) then return false end
	if cp2 and ((cp2~=tp and cp2~=PLAYER_ALL) or cv2&LOCATION_HAND==0) then return false end
	if cp3 and ((cp3~=tp and cp3~=PLAYER_ALL) or cv3&LOCATION_HAND==0) then return false end
	if cp4 and ((cp4~=tp and cp4~=PLAYER_ALL) or cv4&LOCATION_HAND==0) then return false end
	return true
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=#g
	if chk==0 then return gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,gc,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=#g
	if gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end