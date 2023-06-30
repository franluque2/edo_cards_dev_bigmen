--Conscription of The Light
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end



--change this to change the locations where this acts
local LOCATIONS=LOCATION_ALL-LOCATION_OVERLAY

--add archetype setcode here
local ARCHETYPE=0x155d

--add the conditions for the archetype swap here
function s.archetypefilter(c)
  return c:IsCode(84425220,79473793,20193924,511000081,511000082,511001350)
end





function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here

        local e6=Effect.CreateEffect(e:GetHandler())
        e6:SetType(EFFECT_TYPE_FIELD)
        e6:SetCode(EFFECT_ADD_SETCODE)
        e6:SetTargetRange(LOCATIONS,0)
        e6:SetTarget(function(_,c) return s.archetypefilter(c) end)
        e6:SetValue(ARCHETYPE)
        Duel.RegisterEffect(e6,tp)

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetTargetRange(LOCATIONS,0)
        e2:SetValue(ATTRIBUTE_LIGHT)
        Duel.RegisterEffect(e2,tp)
    

	end
	e:SetLabel(1)
end


function s.markedfilter(c,e)
    return #c:IsHasEffect(e)>0
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local armeddragons=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, LOCATION_ALL, nil,84425220)

    if #armeddragons>0 then
		local tc=armeddragons:GetFirst()
		while tc do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,0))
            e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
            e1:SetType(EFFECT_TYPE_IGNITION)
            e1:SetRange(LOCATION_HAND)
            e1:SetCountLimit(1,{id,0})
            e1:SetCost(s.spcost)
            e1:SetTarget(s.sptg)
            e1:SetOperation(s.spop)
            tc:RegisterEffect(e1)


			tc=armeddragons:GetNext()
		end
	end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.rescon(sg,e,tp,mg,c)
	local sum=sg:GetSum(Card.GetLevel)
	return aux.ChkfMMZ(1)(sg,nil,tp) and sum>=10
end
function s.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:HasLevel() and c:IsSetCard(0x155d) and aux.SpElimFilter(c,true,true)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon,nil,false)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsCode(49306994) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
		and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		c:CompleteProcedure()
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end