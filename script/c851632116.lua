--Vampire Reflection
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONJURE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.selfreleasecost)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.adcon)
	e2:SetOperation(s.adop)
	c:RegisterEffect(e2)

end
s.listed_series={SET_VAMPIRE}

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsFacedown, tp, 0, LOCATION_EXTRA, nil)>0
end

function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_VAMPIRE,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end


function s.adop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
    Duel.ConfirmCards(tp,g)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local tocopy=g:FilterSelect(tp,Card.IsFacedown,1,1,nil):GetFirst()
    if tocopy then

        Duel.ConfirmCards(1-tp, tocopy)
        local c=e:GetHandler()
        local token=Duel.CreateToken(tp, tocopy:GetOriginalCode())
        
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_SETCODE)
        e1:SetValue(SET_VAMPIRE)
        token:RegisterEffect(e1)

        local e2=e1:Clone()
        e2:SetCode(EFFECT_CHANGE_RACE)
        e2:SetValue(RACE_ZOMBIE)
        token:RegisterEffect(e2)


        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetDescription(aux.Stringid(id, 1))
        e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
        e3:SetCode(EFFECT_SPSUMMON_PROC)
        e3:SetRange(LOCATION_EXTRA)
        e3:SetCondition(s.hspcon)
        e3:SetTarget(s.hsptg)
        e3:SetOperation(s.hspop)
        token:RegisterEffect(e3)

        
        Duel.SendtoDeck(token, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
        token:RegisterFlagEffect(0,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
        Duel.ConfirmCards(1-tp, token)

    end
end


function s.hspfilter(c,tp,sc)
	return c:IsSetCard(SET_VAMPIRE) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(c:GetControler(),s.hspfilter,2,false,2,true,c,c:GetControler(),nil,false,nil,tp,c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.hspfilter,2,2,false,true,true,c,nil,nil,false,nil,tp,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
	c:SetMaterial(g)
	g:DeleteGroup()
end