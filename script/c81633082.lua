--The Punchline
local s,id=GetID()
function s.initial_effect(c)
    

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_STARTUP)
    e0:SetCountLimit(1)
    e0:SetRange(0x5f)
    e0:SetOperation(s.flipopextra)
    c:RegisterEffect(e0)

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
        
        --skip to next turn if first
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
        e2:SetCondition(s.skipcon)
        e2:SetOperation(s.skipop)
        Duel.RegisterEffect(e2,tp)

	end
	e:SetLabel(1)
end


function s.monstersswapfilter(c)
    return c:IsMonster() and c:GetOwner()==c:GetControler()
end

function s.backrowswapfilter(c)
    return c:IsSpellTrap() and c:GetOwner()==c:GetControler()
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetFlagEffect(tp, id)==0 and ((Duel.GetTurnCount()==5 and Duel.GetFlagEffect(tp, id+1)==0) or Duel.GetTurnCount()==6)
end

local BackrowTargets={71044499,34646691,97077563,14087893,38699854,5318639,88279736,83258273,12470447,82828051,35686187,83133491}
local MonsterTargets={66602787,67696066,93889755,13215230,52624755,42647539,58268433,34853266,2326738}

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL,tp,id)
	Duel.Hint(HINT_CARD,tp,id)

    local monsters=Duel.GetMatchingGroup(s.monstersswapfilter, tp, LOCATION_ALL-LOCATION_OVERLAY-LOCATION_EXTRA, 0, nil)
    local backrow=Duel.GetMatchingGroup(s.backrowswapfilter, tp, LOCATION_ALL-LOCATION_OVERLAY-LOCATION_EXTRA, 0, nil)

    for tc in monsters:Iter() do
        tc:Recreate(MonsterTargets[ Duel.GetRandomNumber(1, #MonsterTargets ) ], nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
    end

    for tc in backrow:Iter() do
        if tc:GetLocation()==LOCATION_SZONE and tc:IsFaceup() then
            Duel.SendtoHand(tc, tp, REASON_RULE)
        end
        tc:Recreate(BackrowTargets[ Duel.GetRandomNumber(1, #BackrowTargets ) ], nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
    end

	Duel.RegisterFlagEffect(tp,id,0,0,0)
end


function s.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1 and Duel.GetTurnPlayer()~=tp
end
function s.skipop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCode(EFFECT_SKIP_DP)
    e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
    Duel.RegisterEffect(e1,tp)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_SKIP_BP)
    e2:SetReset(RESET_PHASE+PHASE_BATTLE_START+RESET_OPPO_TURN)
    Duel.RegisterEffect(e2, tp)

    local turnp=Duel.GetTurnPlayer()
    Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
    Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
    Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BP)
    e2:SetTargetRange(1,0)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,turnp)

    Duel.RegisterFlagEffect(tp, id+1, 0, 0, 0)
end







function s.shifter(c)
	return c:IsCode(91800273)
end

function s.level4(c)
    return c:IsLevel(4)
end

function s.conttrap(c)
    return c:IsType(TYPE_CONTINUOUS) and c:IsTrap()
end

function s.flipopextra(e,tp,eg,ep,ev,re,r,rp)
	local shifter=Duel.GetFirstMatchingCard(s.shifter, tp, LOCATION_DECK, 0, nil)
    local conttrap=Duel.GetFirstMatchingCard(s.conttrap, tp, LOCATION_DECK, 0, nil)
    local level4=Duel.GetFirstMatchingCard(s.level4, tp, LOCATION_DECK, 0, nil)

    Duel.DisableShuffleCheck()

	if shifter then
		Duel.MoveSequence(shifter,0)
	end

    if conttrap then
		Duel.MoveSequence(conttrap,0)
	end

    if level4 then
		Duel.MoveSequence(level4,0)
	end

    Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_RULE)

    Duel.DisableShuffleCheck(false)

end