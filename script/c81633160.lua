--The Pendulum of Ruin
local s,id=GetID()
function s.initial_effect(c)

	
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_STARTUP)
	e0:SetCountLimit(1)
	e0:SetRange(0x5f)
	e0:SetLabel(0)
	e0:SetOperation(flipopextragaia)
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



function s.startergaiafilter(c)
	return not c:IsCode(40089744,34130561,73129314,50354944,53129443,83764718,5318639,38590361,70828912,49328340,46986414,1248895,56461575)
end

function s.topstarterfilter(c)
	return s.startergaiafilter(c) and c:GetSequence()>=25
end

function s.bottomofdeckfilter(c)
	return c:GetSequence()<=25 and (not s.startergaiafilter(c)) and (not c:IsType(TYPE_SKILL))
end
function s.flipopextragaia()

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

    local purpoison=Duel.CreateToken(tp, 48461764)
    Duel.SendtoHand(purpoison, tp, REASON_RULE)

    local blackfang=Duel.CreateToken(tp, 75672051)
    Duel.SendtoHand(blackfang, tp, REASON_RULE)

end
