--Brask, Titan of Domination
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)


    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    c:RegisterEffect(e3)
	
end

function s.filter2(c,e,tp)
	return c:IsControlerCanBeChanged()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter2(chkc,e,tp) end
	if chk==0 then return true end
	if  Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_CONTROL)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
	end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetDescription(aux.Stringid(id,1))
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e2:SetTargetRange(1,0)
        e2:SetTarget(function(_,c) return c:IsCode(id) end)
        e2:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e2,tp)
end


function s.spfilter(c)
	return c:IsMonster() and ((c:IsFaceup() and aux.SpElimFilter(c)) or not c:IsOnField()) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.rescon(sg,e,tp)
	return aux.ChkfMMZ(1)(sg,e,tp,nil) and sg:GetClassCount(Card.GetRace)==#sg,sg:GetClassCount(Card.GetRace)~=#sg
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA,0,e:GetHandler())
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #rg>2
		and aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	g:DeleteGroup()
end