--Dilrak, Grand Tech Hierophant
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_TECHMINATOR),3,3)

	c:SetUniqueOnField(1,0,id)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.znval)
	c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():IsLinked() end)
	e2:SetValue(aux.imval2)
	c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetDescription(aux.Stringid(id, 1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.gysptg)
	e3:SetOperation(s.gyspop)
	c:RegisterEffect(e3)


    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetDescription(aux.Stringid(id, 2))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
    e2:SetCost(s.cpcst)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)


end

s.listed_series={SET_TECHMINATOR,SET_DIKTAT}


function s.cpcst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cpfilter,1,1,REASON_COST+REASON_DISCARD)
    local g=Duel.GetOperatedGroup()
	e:SetLabelObject(g:GetFirst())

end

function s.cpfilter(c)
	return c:IsSetCard(SET_DIKTAT) and (c:IsNormalSpell() or c:IsNormalTrap())
		and c:IsDiscardable() and c:CheckActivateEffect(false,true,false)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
    local tc=e:GetLabelObject()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te or not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.gyspfilter(c,e,tp)
	return c:IsLinkMonster() and c:IsSetCard(SET_TECHMINATOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK):GetToBeLinkedZone(c,tp,true))
end

function s.znval(e)
	return ~(e:GetHandler():GetLinkedZone()&0x60)
end


function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyspfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_LINK):GetToBeLinkedZone(tc,tp,true)) then
            if Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
                if #g>0 then
                    Duel.HintSelection(g,true)
                    Duel.SendtoGrave(g,REASON_EFFECT)
                end
        
            end
        end
	end
end
