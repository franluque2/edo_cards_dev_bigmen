

local function startergaiafilter(c)
	return not c:IsCode(40089744,34130561,73129314,50354944,53129443,83764718,5318639,38590361,70828912,49328340,46986414,1248895,56461575)
end

local function topstarterfilter(c)
	return startergaiafilter(c) and c:GetSequence()>25
end

local function bottomofdeckfilter(c)
	return c:GetSequence()<=25 and (not startergaiafilter(c)) and (not c:IsType(TYPE_SKILL))
end
local function flipopextragaia()

	if not Duel.IsExistingMatchingCard(Card.IsCode, 0, LOCATION_ALL, LOCATION_ALL, 1, nil, 15989522) then return end

    local tp=0
    if Duel.IsExistingMatchingCard(Card.IsCode, 0, LOCATION_ALL, 0, 1, nil, 15989522) then tp=0 else tp=1 end
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
end

local e1=Effect.GlobalEffect()
e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e1:SetCode(EVENT_STARTUP)
e1:SetCountLimit(1)
e1:SetRange(0x5f)
e1:SetLabel(0)
e1:SetOperation(flipopextragaia)
Duel.RegisterEffect(e1, 0)

-- end