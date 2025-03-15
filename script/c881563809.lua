--Minecraft Structure: Nether Portal
Duel.LoadScript ("wb_aux.lua")
Duel.LoadScript ("wb_aprilfools_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)


	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONJURE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end


function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_ROCK,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local e0=Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp, 881563810, SET_MINECRAFT, TYPE_EFFECT+TYPE_XYZ, 2800, 200, 8, RACE_FIEND, ATTRIBUTE_FIRE)
    local e1=Duel.GetLocationCount(tp, LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and Duel.IsPlayerCanSpecialSummonMonster(tp, 881563811, SET_MINECRAFT, TYPE_EFFECT+TYPE_XYZ, 2200, 1000, 4, RACE_FIEND, ATTRIBUTE_FIRE)
	if chk==0 then return e0 or e1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local op=Duel.SelectEffect(tp,{e0,aux.Stringid(id,0)},{e1,aux.Stringid(id,1)})
	e:SetLabel(op)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local token=Duel.CreateToken(tp, 881563810)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)

		local mat1=Duel.CreateToken(tp, 881563811)
            Duel.SendtoGrave(mat1, REASON_RULE)
            Duel.Overlay(token,mat1)
    
            local mat2=Duel.CreateToken(tp, 881563811)
            Duel.SendtoGrave(mat2, REASON_RULE)
            Duel.Overlay(token,mat2)
	else
		if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then return end
		local token=Duel.CreateToken(tp, 881563811)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local token2=Duel.CreateToken(tp, 881563811)
		Duel.SpecialSummonStep(token2,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
