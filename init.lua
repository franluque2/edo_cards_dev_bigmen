
local brickshero={10186633,45906428,80170678,89058026,16169772,75047173,24094653,78371393,5126490,40740224,5318639,95286165,37412656,48130397}

local function starterherofilter(c)
	return not c:IsOriginalCode(table.unpack(brickshero))
end

local function topstarterfilter(c)
	return starterherofilter(c) and c:GetSequence()>=30
end

local function bottomofdeckfilter(c)
	return c:GetSequence()<=30 and (not starterherofilter(c)) and (not c:IsType(TYPE_SKILL))
end
local function flipopextrahero()
	if not Duel.IsExistingMatchingCard(Card.IsCode, 0, LOCATION_ALL, LOCATION_ALL, 1, nil, 56733747) then return end
    local tp=0
    if Duel.IsExistingMatchingCard(Card.IsCode, 0, LOCATION_ALL, 0, 1, nil, 56733747) then tp=0 else tp=1 end
	local starters=Duel.GetMatchingGroup(topstarterfilter, tp, LOCATION_DECK, 0, nil)
	local bottomcards=Duel.GetMatchingGroup(bottomofdeckfilter, tp, LOCATION_DECK, 0, nil)

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


local bricksaa={13662809,23784496,33503878,50179591,87390798,41803903,70564929,86578200,77297908,4682617,59057953,5318639}


local function starteraafilter(c)
	return not c:IsOriginalCode(table.unpack(bricksaa))
end

local function topstarteraafilter(c)
	return starteraafilter(c) and c:GetSequence()>=30
end

local function bottomofdeckaafilter(c)
	return c:GetSequence()<=30 and (not starteraafilter(c)) and (not c:IsType(TYPE_SKILL))
end

local function flipopextraaa()
	if not Duel.IsExistingMatchingCard(Card.IsCode, 0, LOCATION_ALL, LOCATION_ALL, 1, nil, 02368215) then return end
    local tp=0
    if Duel.IsExistingMatchingCard(Card.IsCode, 0, LOCATION_ALL, 0, 1, nil, 02368215) then tp=0 else tp=1 end
	local starters=Duel.GetMatchingGroup(topstarteraafilter, tp, LOCATION_DECK, 0, nil)
	local bottomcards=Duel.GetMatchingGroup(bottomofdeckaafilter, tp, LOCATION_DECK, 0, nil)

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

local e1=Effect.GlobalEffect()
e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e1:SetCode(EVENT_STARTUP)
e1:SetCountLimit(1)
e1:SetRange(0x5f)
e1:SetLabel(0)
e1:SetOperation(flipopextrahero)
Duel.RegisterEffect(e1, 0)

local e2=e1:Clone()
e2:SetOperation(flipopextraaa)
Duel.RegisterEffect(e2, 0)


-- end