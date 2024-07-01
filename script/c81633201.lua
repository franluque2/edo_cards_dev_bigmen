--Shackles of a Dark Performer
--restrict template
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

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    

        local e7=Effect.CreateEffect(e:GetHandler())
        e7:SetType(EFFECT_TYPE_FIELD)
        e7:SetCode(EFFECT_IMMUNE_EFFECT)
        e7:SetTargetRange(LOCATION_MZONE,0)
        e7:SetTarget(function (_,c) return not (c:IsSetCard(SET_PERFORMAGE) and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_XYZ))) end)
        e7:SetValue(s.efilter)
        Duel.RegisterEffect(e7, tp)

        local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetCode(EFFECT_DISABLE)
        e9:SetTargetRange(LOCATION_ONFIELD,0)
        e9:SetCondition(s.discon)
        e9:SetTarget(aux.TargetBoolFunction(Card.IsCode,100305024))
        Duel.RegisterEffect(e9, tp)


        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_CHAIN_SOLVING)
        e2:SetCondition(s.negcon)
        e2:SetOperation(s.negop)
        Duel.RegisterEffect(e2, tp)
    
	end
	e:SetLabel(1)
end

function s.check(ev,re)
	return function(category,checkloc)
		if not checkloc and re:IsHasCategory(category) then return true end
		local ex1,g1,gc1,dp1,dv1=Duel.GetOperationInfo(ev,category)
		local ex2,g2,gc2,dp2,dv2=Duel.GetPossibleOperationInfo(ev,category)
		if not (ex1 or ex2) then return false end
		if category==CATEGORY_DRAW or category==CATEGORY_DECKDES then return true end
		local g=Group.CreateGroup()
		if g1 then g:Merge(g1) end
		if g2 then g:Merge(g2) end
		return (((dv1 or 0)|(dv2 or 0))&LOCATION_DECK)~=0 or (#g>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK))
	end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer() ~=e:GetHandlerPlayer()
end

function s.adpolyfilter(c)
    return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToHand()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local checkfunc=s.check(ev,re)
	return rp==tp and Duel.IsChainDisablable(ev) and Duel.IsExistingMatchingCard(s.adpolyfilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil)  and (checkfunc(CATEGORY_TOHAND,true)
     or checkfunc(CATEGORY_SPECIAL_SUMMON,true) or checkfunc(CATEGORY_DRAW,true) or checkfunc(CATEGORY_DRAW,false)
    or checkfunc(CATEGORY_SEARCH,false))
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if (Duel.GetRandomNumber(0,10)<5) then
        Duel.Hint(HINT_CARD, tp, id)
        if Duel.NegateEffect(ev) then
            local g=Duel.GetMatchingGroup(s.adpolyfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
            local sg=Group.RandomSelect(g, tp, 1, nil)
            Duel.SendtoHand(sg, tp, REASON_RULE)
            Duel.ConfirmCards(1-tp, sg)
        end

	end
end




function s.efilter(e,te)
	return e:GetOwnerPlayer()==te:GetOwnerPlayer() and te:GetHandler():IsCode(100305022)
end




function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

    local witches=Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ALL, 0, nil, 100305022)
    for tc in witches:Iter() do
        tc:SetUniqueOnField(1,0,100305022)
    end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
