--Galvanized Steel Knight Valfram
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    Link.AddProcedure(c,s.matfilter,2,3,s.lcheck)
	c:EnableReviveLimit()

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.znval)
	c:RegisterEffect(e1)
	
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)



end
s.listed_card_types={TYPE_GEMINI}


function s.znval(e)
	return ~(e:GetHandler():GetLinkedZone()&0x60)
end

function s.noneffectfilter(c,lc,sumtype,tp)
    return not c:IsType(TYPE_EFFECT,lc,sumtype,tp)
end

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(s.noneffectfilter,1,nil,lc,sumtype,tp)
end

function s.matfilter(c,lc,sumtype,tp)
	return not c:IsType(TYPE_TOKEN,lc,sumtype,tp)
end

function s.filter(c,e,tp)
	return c:IsType(TYPE_GEMINI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then

        Duel.SpecialSummonComplete()
        Duel.BreakEffect()
        if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
        --treated as Link Spell
        local e1=Effect.CreateEffect(c)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(TYPE_SPELL+TYPE_LINK)
        c:RegisterEffect(e1)

        local e5=Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetRange(LOCATION_SZONE)
        e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
        e5:SetReset(RESET_EVENT+RESETS_STANDARD)
        e5:SetTarget(s.chtg)
        e5:SetCode(EFFECT_GEMINI_STATUS)
        c:RegisterEffect(e5)
        end

    end
end


function s.chtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsType(TYPE_GEMINI)
end