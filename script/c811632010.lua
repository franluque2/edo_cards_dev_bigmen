--Balanced Beginnings
Duel.LoadScript("big_aux.lua")

local s,id=GetID()
function s.initial_effect(c)

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_STARTUP)
    e0:SetCountLimit(1)
    e0:SetRange(0x5f)
    e0:SetOperation(s.flipopextra)
    c:RegisterEffect(e0)

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

	end
	e:SetLabel(1)
end





function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetFlagEffect(tp, id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)


	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.validcardfilter(c)
    return c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP) or c:IsType(TYPE_MONSTER)
end

function s.flipopextra(e,tp,eg,ep,ev,re,r,rp)

    local totalcards=Duel.GetMatchingGroupCount(s.validcardfilter, tp, LOCATION_DECK, 0, nil)
    local mons=Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_DECK, 0, nil, TYPE_MONSTER)
    local spells=Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_DECK, 0, nil, TYPE_SPELL)
    local traps=Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_DECK, 0, nil, TYPE_TRAP)

    local cardnums={}
    cardnums[0] = 0 --monstosend
    cardnums[1]=0 --spellstosend
    cardnums[2]=0 --trapstosend

    if mons then
        cardnums[0]=math.ceil((#mons)/totalcards*5)
    end
    if spells then
        cardnums[1]=math.ceil((#spells)/totalcards*5)
    end
    if traps then
        cardnums[2]=math.ceil((#traps)/totalcards*5)
    end

    local highest=0
    if cardnums[1]>cardnums[highest] then
        highest=1
    end
    if cardnums[2]>cardnums[highest] then
        highest=2
    end

    local total=cardnums[0]+cardnums[1]+cardnums[2]
    if total>5 then
        cardnums[highest]=cardnums[highest]-1
    end

    local highest=0
    if cardnums[1]>cardnums[highest] then
        highest=1
    end
    if cardnums[2]>cardnums[highest] then
        highest=2
    end

    local total=cardnums[0]+cardnums[1]+cardnums[2]
    if total>5 then
        cardnums[highest]=cardnums[highest]-1
    end

    for i = 1, cardnums[0], 1 do
        local card=Group.GetFirst(mons)
        Duel.MoveSequence(card,0)
        Group.RemoveCard(mons, card)

    end
    for i = 1, cardnums[1], 1 do
        local card=Group.GetFirst(spells)
        Duel.MoveSequence(card,0)
        Group.RemoveCard(spells, card)

    end
    for i = 1, cardnums[2], 1 do
        local card=Group.GetFirst(traps)
        Duel.MoveSequence(card,0)
        Group.RemoveCard(traps, card)

    end

    Duel.DisableShuffleCheck(false)

end