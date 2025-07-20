--Skilled? Princess Pikeru
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)


    	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_DEFENSE)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)


    	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTarget(s.rectg)
	e3:SetOperation(s.recop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

    aux.GlobalCheck(s,function()
        s.lpgained={}
        s.lpgained[0]=0
        s.lpgained[1]=0
        local ge0=Effect.CreateEffect(c)
        ge0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge0:SetCode(EVENT_ADJUST)
        ge0:SetOperation(function()
            s.lpgained[0]=0
            s.lpgained[1]=0
        end)
        ge0:SetCountLimit(1)
        Duel.RegisterEffect(ge0,0)
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_RECOVER)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    s.lpgained[ep]=s.lpgained[ep]+ev
end


function s.value(e,c)
	return s.lpgained[c:GetControler()]
end


function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local val=Duel.GetMatchingGroupCount(aux.TRUE, tp, LOCATION_MZONE, 0, e:GetHandler())*600
	Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(val)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,val,REASON_EFFECT)
end