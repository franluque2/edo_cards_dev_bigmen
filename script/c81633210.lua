--Legacy of the Dueltaining Pioneer
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_STARTUP)
    e0:SetCountLimit(1)
    e0:SetRange(0x5f)
    e0:SetOperation(s.flipopextra)
    --c:RegisterEffect(e0)

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

local CARD_PAPER_DOLL=511009320

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

		--other passive duel effects go here    

        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetTargetRange(1,0)
        e2:SetTarget(s.splimit)
        Duel.RegisterEffect(e2,tp)

        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_ADD_SETCODE)
        e3:SetTargetRange(LOCATION_ALL, 0)
        e3:SetTarget( function(_, c) return c:IsOriginalSetCard(0x9f) end)
        e3:SetValue(0xc6)
        Duel.RegisterEffect(e3, tp)

        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_ADD_CODE)
        e4:SetTargetRange(LOCATION_GRAVE, 0)
        e4:SetTarget( function(_, c) return c:IsOriginalSetCard(0x9f) and c:IsLevelAbove(7) end)
        e4:SetValue(CARD_DARK_MAGICIAN)
        Duel.RegisterEffect(e4, tp)

        
        local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_DRAW)
		e5:SetCondition(s.drawcon)
		e5:SetOperation(s.drawop)
		Duel.RegisterEffect(e5,tp)



        local e6=Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_TO_GRAVE)
		e6:SetCondition(s.adcon)
		e6:SetOperation(s.adop)
        e6:SetCountLimit(1,id)
		Duel.RegisterEffect(e6,tp)

        local e7=e6:Clone()
        e7:SetCode(EVENT_REMOVE)
        Duel.RegisterEffect(e7,tp)


        local e8=Effect.CreateEffect(e:GetHandler())
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e8:SetProperty(EFFECT_FLAG_DELAY)
		e8:SetCode(EVENT_TO_HAND)
		e8:SetCondition(s.scon0)
		e8:SetOperation(s.sop0)
        e8:SetCountLimit(1)
		Duel.RegisterEffect(e8,tp)


        local e9=Effect.CreateEffect(e:GetHandler())
		e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e9:SetProperty(EFFECT_FLAG_DELAY)
		e9:SetCode(EVENT_TO_HAND)
		e9:SetCondition(s.scon2)
		e9:SetOperation(s.sop2)
		Duel.RegisterEffect(e9,tp)

        local e11=Effect.CreateEffect(e:GetHandler())
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_SPSUMMON_PROC)
    e11:SetDescription(aux.Stringid(id, 1))
	e11:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e11:SetRange(LOCATION_GRAVE|LOCATION_HAND)
	e11:SetCondition(s.spcon)
	e11:SetTarget(s.sptg)
	e11:SetOperation(s.spop)
    e11:SetCountLimit(1, id)

    local e12=Effect.CreateEffect(e:GetHandler())
	e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e12:SetTargetRange(LOCATION_GRAVE|LOCATION_HAND,0)
	e12:SetTarget(function(e,c) return c:IsCode(36527535) end)
	e12:SetLabelObject(e11)
	Duel.RegisterEffect(e12,tp)
	end
	e:SetLabel(1)
end

function s.spfilter(c,tp)
	return c:IsAbleToHandAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if (not op or op(e,c)) and c:IsLocation(LOCATION_GRAVE) then return false end
	end
	local tp=c:GetControler()
	return aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RTOHAND,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoHand(g,nil,REASON_COST)
	g:DeleteGroup()
end

function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsMonster() and c:IsReason(REASON_EFFECT)
end

function s.shufflefilter(c)
    return c:IsAbleToDeckAsCost() and not c:IsCode(CARD_PAPER_DOLL)
end

function s.addfilter(c)
    return c:IsAbleToHand() and ( c:IsSetCard(0x98) and c:IsSpell() and c:IsType(TYPE_CONTINUOUS)) or (c:IsSetCard(0x125) and c:IsSpellTrap()) or c:IsCode(511009397)
end

function s.scon2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetCurrentPhase()==PHASE_DRAW then return false end
	if not (rp==tp and ep==tp) then return false end
    return eg:IsExists(s.cfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.shufflefilter, tp, LOCATION_HAND, 0, 1, nil) and
    Duel.IsExistingMatchingCard(s.addfilter, tp, LOCATION_DECK, 0, 1, nil)
    and Duel.GetFlagEffect(tp, id+1)==0
end


function s.sop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
    Duel.Hint(HINT_CARD,tp,id)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local toshuffle=Duel.SelectMatchingCard(tp, s.shufflefilter, tp, LOCATION_HAND, 0, 1,1,false,nil)
    if Duel.SendtoDeck(toshuffle, tp, SEQ_DECKSHUFFLE, REASON_RULE) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local toadd=Duel.SelectMatchingCard(tp, s.addfilter, tp, LOCATION_DECK, 0, 1,1,false,nil)
        Duel.SendtoHand(toadd, tp, REASON_RULE)
        Duel.ConfirmCards(1-tp, toadd)
    end
    Duel.RegisterFlagEffect(tp, id+1, 0,0,0)
    end
end

function s.scon0(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetCurrentPhase()==PHASE_DRAW then return false end
    if eg and Card.IsReason(eg:GetFirst(), REASON_RULE) then return false end
	if not (rp==tp and ep==tp) then return false end
    local num=Duel.GetRandomNumber(0,100)
    return num>50
end

function s.sop0(e,tp,eg,ep,ev,re,r,rp)
    
        Duel.Hint(HINT_CARD, tp, id)
        local pdoll=Duel.CreateToken(tp, CARD_PAPER_DOLL)
        Duel.SendtoHand(pdoll, tp, REASON_RULE, false)

end


function s.adbackfilter(c, tp)
    return c:IsCode(CARD_PAPER_DOLL) and c:IsAbleToHand() and c:IsOwner(tp)
end

function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.adbackfilter, 1, nil, tp)
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)

    local doll=eg:Filter(s.adbackfilter, nil, tp)
    Duel.SendtoHand(doll, tp, REASON_RULE)

end


function s.drawcon(e,tp,eg,ep,ev,re,r,rp)

    if not eg then return end
    if not eg:GetFirst():GetReasonEffect() then return end
    if ep~=tp then return end
	return eg and Card.GetReasonEffect(eg:GetFirst()):GetHandler():IsCode(19162134)
        and Duel.IsPlayerCanDraw(tp)
end

function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    	Duel.Hint(HINT_CARD, tp, id)
        Duel.Draw(tp, 2, REASON_RULE)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

function s.flipopextra(e,tp,eg,ep,ev,re,r,rp)

    Duel.DisableShuffleCheck()

    local pdoll=Duel.CreateToken(tp, CARD_PAPER_DOLL)
    Duel.SendtoDeck(pdoll, tp, SEQ_DECKTOP, REASON_RULE)

	Duel.MoveSequence(pdoll,0)

    Duel.DisableShuffleCheck(false)

end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)

	local Dueltaining=Duel.CreateToken(tp, 19162134)
	Duel.ActivateFieldSpell(Dueltaining,e,tp,eg,ep,ev,re,r,rp)

    local pdoll=Duel.CreateToken(tp, CARD_PAPER_DOLL)
    Duel.SendtoHand(pdoll, tp, REASON_RULE)

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
