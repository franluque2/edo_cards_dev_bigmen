--Minecraft Structure: Enchanting Table
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)	
    c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,1,s.ffilter2,1)

    c:SetUniqueOnField(1,0,id)



    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(500)
	--Def up
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)


    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DISABLE)
    e3:SetCondition(aux.NOT,s.atkcon)

    local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_EQUIP)
	e11:SetCode(EFFECT_UNRELEASABLE_SUM)
	e11:SetValue(1)
    e11:SetCondition(aux.NOT,s.atkcon)
	local e12=e11:Clone()
	e12:SetCode(EFFECT_UNRELEASABLE_NONSUM)

    local e13=e11:Clone()
	e13:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e13:SetValue(aux.cannotmatfilter(SUMMON_TYPE_LINK))


    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_SZONE,0)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e1)
	c:RegisterEffect(e5)

    local e6=e5:Clone()
    e6:SetLabelObject(e2)
    c:RegisterEffect(e6)

    local e7=e5:Clone()
    e7:SetLabelObject(e3)
    c:RegisterEffect(e7)

    local e8=e5:Clone()
    e8:SetLabelObject(e11)
    c:RegisterEffect(e7)
    local e9=e5:Clone()
    e9:SetLabelObject(e12)
    c:RegisterEffect(e9) 
    local e10=e5:Clone()
    e10:SetLabelObject(e13)
    c:RegisterEffect(e10)

end

function s.atkcon(e)
	local eq=e:GetHandler():GetEquipTarget()
	return eq and eq:GetControler()~=e:GetHandlerPlayer()
end

function s.eftg(e,c)
	return c:IsType(TYPE_EQUIP) and c:IsFaceup()
end

function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp) and c:IsRace(RACE_ROCK,fc,sumtype,tp)
end

function s.ffilter2(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER,fc,sumtype,tp) and c:IsRace(RACE_ROCK,fc,sumtype,tp)
end