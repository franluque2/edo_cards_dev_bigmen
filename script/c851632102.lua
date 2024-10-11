--Mythical Beast Penguin Emperor
Duel.LoadScript ("wb_aux.lua")
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
	Link.AddProcedure(c,s.matfilter,1,1)

	
    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.extraval)
	c:RegisterEffect(e2)
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_ADD_TYPE)
	e2a:SetRange(LOCATION_EXTRA)
	e2a:SetTargetRange(LOCATION_PZONE,0)
	e2a:SetCondition(s.addtypecon)
	e2a:SetTarget(aux.TargetBoolFunction(Card.IsCanAddCounter,COUNTER_SPELL))
	e2a:SetValue(TYPE_MONSTER)
	c:RegisterEffect(e2a)


    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)

end


function s.matfilter(c,sc,st,tp)
	return (c:IsCanAddCounter(COUNTER_SPELL,1,false,LOCATION_MZONE) or c:IsCanAddCounter(COUNTER_SPELL,1,false,LOCATION_SZONE)) and c:IsLocation(LOCATION_PZONE)
end

function s.filter(c)
    return (c:IsCanAddCounter(COUNTER_SPELL,1,false,LOCATION_MZONE) or c:IsCanAddCounter(COUNTER_SPELL,1,false,LOCATION_SZONE))
end
function s.extraval(chk,summon_type,e,...)

	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not (sc and sc==e:GetHandler()) then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(s.filter,tp,LOCATION_PZONE,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end
function s.addtypecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end



function s.thfilter(c)
	return c:IsCode(75014062) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)

	if #tc>0 and Duel.SendtoHand(tc, tp, REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.ConfirmCards(1-tp, tc)
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


        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(id,1))
        e2:SetCategory(CATEGORY_COUNTER)
        e2:SetType(EFFECT_TYPE_IGNITION)
        e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e2:SetRange(LOCATION_SZONE)
        e2:SetCountLimit(1)
        e2:SetTarget(s.tdtarget)
        e2:SetOperation(s.tdoperation)
        c:RegisterEffect(e2)

        end

    end
end


function s.cfilter(c,cg)
	return cg:IsContains(c) and c:IsFaceup() and c:GetCounter(COUNTER_SPELL)>0 and c:IsCanAddCounter(COUNTER_SPELL, c:GetCounter(COUNTER_SPELL))
end

function s.tdtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local cg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return cg:IsExists(s.cfilter, 1, nil,cg) end
    Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_SPELL)
end
function s.tdoperation(e,tp,eg,ep,ev,re,r,rp)
    local cg=e:GetHandler():GetLinkedGroup()

	local tc=cg:GetFirst()
	if tc and tc:IsFaceup() then
        tc:AddCounter(COUNTER_SPELL,tc:GetCounter(COUNTER_SPELL))
	end
end

