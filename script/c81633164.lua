--The Relic
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
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)

    aux.AddSkillProcedure(c,1,false,s.flipcon2,s.flipop2)

end

local bricks={10186633,45906428,80170678,89058026,16169772,75047173,24094653,78371393,5126490,40740224,5318639,95286165,37412656,48130397}

function s.starterfilter(c)
	return not c:IsOriginalCode(table.unpack(bricks))
end

function s.topstarterfilter(c)
	return s.starterfilter(c) and c:GetSequence()>=30
end

function s.bottomofdeckfilter(c)
	return c:GetSequence()<=30 and (not s.starterfilter(c)) and (not c:IsType(TYPE_SKILL))
end

function s.flipopextra(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ALL, 0, 1, nil, 56733747) then return end
	local starters=Duel.GetMatchingGroup(s.topstarterfilter, tp, LOCATION_DECK, 0, nil)
	local bottomcards=Duel.GetMatchingGroup(s.bottomofdeckfilter, tp, LOCATION_DECK, 0, nil)

	Duel.DisableShuffleCheck()

	if starters then
		local prevnum=-1
		while (#starters>0) do

			local cardtotake=starters:GetFirst()
			local cardtoreplace=bottomcards:GetFirst()

			if cardtotake and cardtoreplace then
				Group.RemoveCard(bottomcards, cardtoreplace)
				Group.RemoveCard(starters, cardtotake)

				local starterid=cardtotake:GetOriginalCode()
				local replacedid=cardtoreplace:GetOriginalCode()


				Card.Recreate(cardtotake, replacedid,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
				Card.Recreate(cardtoreplace, starterid,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)

			end
			if not ((#bottomcards)>0) then
				break
			end
			if (#starters==1) then
				if #starters==prevnum then
					break
				end

				prevnum=#starters
			end
		end
	end
	Duel.DisableShuffleCheck(false)

end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)

	end
	e:SetLabel(1)
end



function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,0),nil)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.SendtoDeck(e:GetHandler(), tp, -2, REASON_EFFECT)
	if e:GetHandler():GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end



function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)

	--OPD check
	if Duel.GetFlagEffect(tp,id)>1  then return end

	return aux.CanActivateSkill(tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<5 and Duel.IsPlayerCanDraw(tp,1) and not (Duel.GetCurrentPhase()==PHASE_MAIN2)
end



function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        
	Duel.Hint(HINT_CARD,tp,id)

    local drawnum=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    Duel.Draw(tp, drawnum, REASON_RULE)

    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetTargetRange(1,0)
    e4:SetValue(999999999)
    e4:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e4,tp)

    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetCode(EFFECT_SKIP_M2)
    e5:SetReset(RESET_PHASE+PHASE_END)
    e5:SetTargetRange(1,0)
    Duel.RegisterEffect(e5,tp)

	Duel.RegisterFlagEffect(tp, id, 0, 0, 0)

    end
end
