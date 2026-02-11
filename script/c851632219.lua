--Gravekeeper's Slime
local s,id=GetID()
function s.initial_effect(c)
    	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),s.matfilter)


    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)

    	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.nspcon)
	e3:SetTarget(s.nstg)
	e3:SetOperation(s.nsop)
	c:RegisterEffect(e3)


    	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetTarget(function(e,c) return c:IsSpellTrap() and c:IsFaceup() and c:ListsCode(CARD_RA) end)
	e4:SetValue(1)
	c:RegisterEffect(e4)

end
s.listed_names={CARD_RA}

function s.matfilter(c,fc,sumtype,tp)
	return c:GetLevel()<=10
end


function s.hspfilter(c,tp,sc)
	return c:IsRace(RACE_AQUA) and c:GetLevel()==10 and c:GetAttack()==0 and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end

function s.sendfilter(c)
    return c:IsCode(10000090) and c:IsAbleToGrave()
end

function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.hspfilter,1,false,1,true,c,tp,nil,nil,nil,tp,c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.hspfilter,1,1,false,true,true,c,tp,nil,false,nil,tp,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
    local onfield=g:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	Duel.Release(onfield,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end


function s.nsfilter(c)
	return c:IsCode(CARD_RA) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	--send 1 "The Winged Dragon of Ra - Immortal Phoenix" from the Deck to the GY or pay 1000 LP, then Normal Summon 1 "The Winged Dragon of Ra"

	local g=Duel.GetMatchingGroup(s.sendfilter, tp, LOCATION_DECK, 0, nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	elseif Duel.CheckLPCost(tp, 1000) then
		Duel.PayLPCost(tp,1000)
	else
		return
	end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end

function s.nspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.sendfilter, tp, LOCATION_DECK, 0, 1, nil) or Duel.CheckLPCost(tp, 1000)
end