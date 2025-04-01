--Vegito, Fused Saiyan
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xd02),aux.FilterBoolFunctionEx(Card.IsSetCard,0xd05))
	
	Fusion.AddContactProc(c,s.contactfil,s.contactop,function(e,se,sp,st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st) end,nil,nil,nil,false)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e8:SetValue(1)
	c:RegisterEffect(e8)

    local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_EXTRA_ATTACK)
	e9:SetValue(1)
	c:RegisterEffect(e9)

    local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_SET_ATTACK)
	e10:SetRange(LOCATION_MZONE)
	e10:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e10:SetCondition(s.zeroatkcon)
	e10:SetTarget(function(e,_c) return _c==e:GetHandler():GetBattleTarget() end)
	e10:SetValue(0)
	c:RegisterEffect(e10)


    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.distg)
	c:RegisterEffect(e3)
	--Adjust itself to apply the negation effect right away
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(function(e) Duel.AdjustInstantly(e:GetHandler()) end)
	c:RegisterEffect(e4)

end
s.listed_series={SET_DRAGON_BALL, SET_GOKU, SET_VEGETA}

function s.distg(e,c)
	local fid=e:GetHandler():GetFieldID()
	for _,label in ipairs({c:GetFlagEffectLabel(id)}) do
		if fid==label then return true end
	end
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and bc and bc:IsControler(e:GetHandlerPlayer())
		and bc:IsFaceup() and bc==e:GetHandler() then
		c:RegisterFlagEffect(id,RESETS_STANDARD,0,1,fid)
		return true
	end
	return false
end


function s.zeroatkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
end

function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g,e)
	Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_MATERIAL+REASON_COST)
end