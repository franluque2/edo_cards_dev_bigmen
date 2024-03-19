--Ritual of the Matador (CT)
local s,id=GetID()
function s.initial_effect(c)

	Ritual.AddProcGreater({handler=c,filter=s.ritualfil,lv=6,matfilter=s.filter,location=LOCATION_HAND,requirementfunc=s.getchesspointvalue,desc=aux.Stringid(id,0)})

	Ritual.AddProcGreaterCode(c,6,nil,511000009)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
    e2:SetCountLimit(1,{id,1})
	c:RegisterEffect(e2)
end

s.listed_names={511000009}

function s.filter(c)
	return c:IsSetCard(0x45)
end

function s.getchesspointvalue(c)
	if not s.haschessvalue(c) then return 0 end
	return Chesspointvalues[c:GetCode()]
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsCode(94585852) and c:IsLocation(LOCATION_FZONE)
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
function s.ritualfil(c)
	return c:IsCode(511000009) and c:IsRitualMonster()
end
function s.haschessvalue(c)
    return Chesspointvalues[c:GetOriginalCode()]~=nil
end



Chesspointvalues={}
Chesspointvalues[73219648]=1
Chesspointvalues[72192100]=5
Chesspointvalues[92039899]=3
Chesspointvalues[9603356]=3
Chesspointvalues[35798491]=3
Chesspointvalues[8581705]=9
Chesspointvalues[35975813]=4
Chesspointvalues[52248570]=9
Chesspointvalues[35606858]=4