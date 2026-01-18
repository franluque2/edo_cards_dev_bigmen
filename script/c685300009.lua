--New Orders - Etheric Hathor
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--xyz
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SPELL_XYZ_MAT)
	e2:SetValue(4)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)

    --All Xyz monsters you control gain 500 ATK. 
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.atktg)
    e3:SetValue(500)
    c:RegisterEffect(e3)

    -- All non-Xyz monsters your opponent controls are also treated as Xyz Monsters, using its Level as if it were a Rank.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_ADJUST)
    e4:SetRange(LOCATION_SZONE)
    e4:SetOperation(s.adtypeop)
    c:RegisterEffect(e4)

    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetCode(EFFECT_LEVEL_RANK_S)
	e6:SetTarget(function(e,cc) return cc:HasLevel() end)
	c:RegisterEffect(e6)
end

function s.atktg(e,c)
    return c:IsType(TYPE_XYZ) and c:IsFaceup()
end

function s.scfilter(c)
    return c:IsFaceup() and c:GetFlagEffect(id)==0 and not c:IsOriginalType(TYPE_XYZ)
end

function s.adtypeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.scfilter,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end
    for tc in g:Iter() do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_TYPE)
        e1:SetValue(TYPE_XYZ)
        e1:SetCondition(s.confunc)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
    end
end

function s.nonnegatedspell(c)
    return c:IsOriginalCode(id) and c:IsFaceup() and not c:IsDisabled()
end

function s.confunc(e)
    return Duel.IsExistingMatchingCard(s.nonnegatedspell, e:GetHandler():GetControler(), 0, LOCATION_SZONE, 0, nil)
end